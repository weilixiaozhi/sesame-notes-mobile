import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/application/backup_cleanup_controller.dart';
import 'package:sesame_notes/features/settings/domain/backup_cleanup.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 本机与第三方云端共用只读预览，只有逐个检查及明确确认后才能清理文件。
class BackupCleanupPage extends ConsumerStatefulWidget {
  const BackupCleanupPage({super.key, this.initialSourceId});
  final String? initialSourceId;

  @override
  ConsumerState<BackupCleanupPage> createState() => _BackupCleanupPageState();
}

class _BackupCleanupPageState extends ConsumerState<BackupCleanupPage> {
  List<BackupCleanupSource> _sources = const [];
  BackupCleanupPreview? _preview;
  final _selected = <String>{};
  String? _sourceId;
  String? _checkingKey;
  String? _error;
  bool _busy = true;
  bool _deleting = false;
  int _request = 0;
  BackupCleanupManager? _manager;

  /// 首次来源读取排在构建后，页面持续订阅管理器直到退出。
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadSources(widget.initialSourceId));
  }

  /// 使所有迟到结果失效，关闭页面后不能开始新的检查或删除。
  @override
  void dispose() {
    _request++;
    _manager?.cancelPending();
    super.dispose();
  }

  /// 只读取来源展示身份，配置失效后回到当前仍可用的来源。
  Future<void> _loadSources([String? preferred]) async {
    final request = ++_request;
    if (!mounted) return;
    setState(() {
      _busy = true;
      _error = null;
      _selected.clear();
    });
    try {
      ref.invalidate(backupCleanupSourcesProvider);
      final sources = await ref.read(backupCleanupSourcesProvider.future);
      if (!mounted || request != _request) return;
      final desired = preferred ?? _sourceId ?? 'local';
      final source =
          sources.where((item) => item.id == desired).firstOrNull ??
          sources.firstOrNull;
      if (source == null) {
        throw const BackupCleanupException(BackupCleanupFailure.unavailable);
      }
      setState(() => _sources = sources);
      await _loadPreview(source.id);
    } catch (error, stack) {
      logger.error(
        'BackupCleanupPage',
        '读取备份管理来源失败',
        safeErrorSummary(error),
        stack,
      );
      if (!mounted || request != _request) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  /// 每次预览都清空选择，旧来源的确认和文件身份不能继承到新清单。
  Future<void> _loadPreview(String sourceId) async {
    final request = ++_request;
    if (!mounted) return;
    setState(() {
      _busy = true;
      _sourceId = sourceId;
      _preview = null;
      _checkingKey = null;
      _error = null;
      _selected.clear();
    });
    try {
      final preview = await ref
          .read(backupCleanupManagerProvider)
          .preview(sourceId);
      if (!mounted || request != _request) return;
      setState(() => _preview = preview);
    } catch (error, stack) {
      logger.error(
        'BackupCleanupPage',
        '读取备份清理预览失败',
        safeErrorSummary(error),
        stack,
      );
      if (!mounted || request != _request) return;
      setState(() => _error = _errorText(error));
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  /// 云端检查先说明下载范围和大小，确认只作用于捕获的单个文件及预览。
  Future<void> _inspect(BackupCleanupEntry entry) async {
    final preview = _preview;
    if (_busy || preview == null || !entry.canInspect) return;
    final request = ++_request;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      if (!preview.source.isLocal) {
        final confirmed = await AppDialog.confirm(
          context,
          title: l10n.backupCleanupCloudCheckTitle,
          message: l10n.backupCleanupCloudCheckConfirm(
            entry.fileName,
            _size(entry.sizeBytes),
          ),
          okLabel: l10n.backupCleanupCheck,
        );
        if (!mounted || request != _request || confirmed != true) return;
      }
      setState(() => _checkingKey = entry.key);
      final next = await ref
          .read(backupCleanupManagerProvider)
          .inspect(preview, entry.key);
      if (!mounted || request != _request) return;
      setState(() {
        _preview = next;
        final allowed = next.entries
            .where((item) => item.canDelete)
            .map((item) => item.key)
            .toSet();
        _selected.removeWhere((key) => !allowed.contains(key));
      });
    } catch (error, stack) {
      logger.error(
        'BackupCleanupPage',
        '检查备份文件失败',
        safeErrorSummary(error),
        stack,
      );
      if (!mounted || request != _request) return;
      showToast(context, _errorText(error));
      _selected.clear();
      await _loadPreview(preview.source.id);
    } finally {
      if (mounted && request == _request) {
        setState(() {
          _busy = false;
          _checkingKey = null;
        });
      }
    }
  }

  /// 删除请求固定勾选集合，确认后仍由服务复核范围、来源身份及最新有效备份。
  Future<void> _deleteSelected() async {
    final preview = _preview;
    if (_busy || preview == null || _selected.isEmpty) return;
    final keys = Set<String>.unmodifiable(_selected);
    final request = ++_request;
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final confirmed = await AppDialog.confirm(
        context,
        title: l10n.backupCleanupDeleteTitle,
        message: l10n.backupCleanupDeleteConfirm(keys.length),
        okLabel: l10n.commonDelete,
      );
      if (!mounted || request != _request || confirmed != true) return;
      var allowNoCurrent = false;
      if (!preview.hasCurrentBackup) {
        allowNoCurrent =
            await AppDialog.confirm(
              context,
              title: l10n.backupCleanupNoCurrentTitle,
              message: l10n.backupCleanupNoCurrentConfirm,
              okLabel: l10n.backupCleanupDeleteHistorical,
            ) ==
            true;
        if (!mounted || request != _request || !allowNoCurrent) return;
      }
      setState(() => _deleting = true);
      final result = await ref
          .read(backupCleanupManagerProvider)
          .delete(preview, keys, allowNoCurrentBackup: allowNoCurrent);
      if (!mounted || request != _request) return;
      showToast(
        context,
        result.failedCount == 0
            ? l10n.backupCleanupDeleted(result.deletedCount)
            : l10n.backupCleanupPartial(
                result.deletedCount,
                result.failedCount,
              ),
      );
      await _loadPreview(preview.source.id);
    } catch (error, stack) {
      logger.error(
        'BackupCleanupPage',
        '删除所选备份失败',
        safeErrorSummary(error),
        stack,
      );
      if (!mounted || request != _request) return;
      showToast(context, _errorText(error));
      _selected.clear();
      await _loadPreview(preview.source.id);
    } finally {
      if (mounted) setState(() => _deleting = false);
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  /// 页面只使用固定友好文案，底层连接、路径和凭据详情不进入提示。
  String _errorText(Object error) {
    final l10n = AppLocalizations.of(context);
    if (error is! BackupCleanupException) return l10n.backupCleanupUnavailable;
    return switch (error.reason) {
      BackupCleanupFailure.busy ||
      BackupCleanupFailure.inUse => l10n.backupCleanupBusy,
      BackupCleanupFailure.stalePreview ||
      BackupCleanupFailure.fileChanged => l10n.backupCleanupChanged,
      BackupCleanupFailure.protectedBackup ||
      BackupCleanupFailure.noCurrentBackup => l10n.backupCleanupKeepCurrent,
      BackupCleanupFailure.unverified => l10n.backupCleanupCheckFirst,
      BackupCleanupFailure.unavailable => l10n.backupCleanupUnavailable,
    };
  }

  /// 大小仅展示已知元数据，未知大小不作估算。
  String _size(int? bytes) {
    if (bytes == null || bytes < 0) {
      return AppLocalizations.of(context).backupCleanupSizeUnknown;
    }
    return bytes >= 1024 * 1024
        ? '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB'
        : '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  /// 文件状态和最新有效快照保护均来自服务，不依文件名在界面猜测。
  String _status(BackupCleanupEntry entry) {
    final l10n = AppLocalizations.of(context);
    if (entry.isProtected) return l10n.backupCleanupProtected;
    return switch (entry.status) {
      BackupCleanupStatus.unverified => l10n.backupCleanupUnverified,
      BackupCleanupStatus.current => l10n.backupCleanupCurrent,
      BackupCleanupStatus.unsupported => l10n.backupCleanupUnsupported,
      BackupCleanupStatus.auxiliary => l10n.backupCleanupAuxiliary,
      BackupCleanupStatus.unknown => l10n.backupCleanupUnknown,
      BackupCleanupStatus.pending => l10n.backupCleanupPending,
      BackupCleanupStatus.inUse => l10n.backupCleanupInUse,
    };
  }

  /// 行内只允许检查或选择已经核实的文件，读取中和受保护项保持只读。
  Widget _fileTile(BackupCleanupEntry entry) {
    final l10n = AppLocalizations.of(context);
    final date = entry.createdAt ?? entry.modifiedAt;
    final details = <String>[
      if (date != null) DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal()),
      _size(entry.sizeBytes),
    ].join(' · ');

    /// 只允许当前清单中已经核验的文件进入显式选择集合。
    void select(bool? selected) {
      if (_busy || !entry.canDelete) return;
      setState(() {
        if (selected == true) {
          _selected.add(entry.key);
        } else {
          _selected.remove(entry.key);
        }
      });
    }

    return SectionCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p4,
      ),
      child: AppListTile(
        leadingWidget: entry.canDelete
            ? Checkbox(
                key: ValueKey('backup-cleanup-select:${entry.key}'),
                value: _selected.contains(entry.key),
                onChanged: _busy ? null : select,
              )
            : Icon(
                entry.isProtected ? AppIcons.verified : AppIcons.folder,
                size: AppDimens.icon22,
                color: AppTokens.iconTertiary(context),
              ),
        title: entry.fileName,
        subtitle: [
          details,
          _status(entry),
          if (!entry.deletionSupported &&
              entry.sha256 != null &&
              _preview?.supportsDeletion == true)
            l10n.backupCleanupReadOnlyHint,
        ].join('\n'),
        titleMaxLines: null,
        subtitleMaxLines: null,
        onTap: entry.canDelete && !_busy
            ? () => select(!_selected.contains(entry.key))
            : null,
        trailing: _checkingKey == entry.key
            ? const SizedBox.square(
                dimension: AppDimens.icon20,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimens.progressStrokeWidth,
                ),
              )
            : entry.canInspect
            ? TextButton(
                key: ValueKey('backup-cleanup-inspect:${entry.key}'),
                onPressed: _busy ? null : () => _inspect(entry),
                child: Text(l10n.backupCleanupCheck),
              )
            : null,
      ),
    );
  }

  /// 来源和操作区复用项目卡片、标题及按钮，保留系统字号下的自然换行。
  @override
  Widget build(BuildContext context) {
    _manager = ref.watch(backupCleanupManagerProvider);
    final l10n = AppLocalizations.of(context);
    final preview = _preview;
    // 来源、提示和错误区数量固定，历史文件行由滚动列表按可见范围构建。
    final headers = <Widget>[
      const SizedBox(height: AppDimens.p16),
      if (_sources.isNotEmpty)
        SectionCard(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
          child: DropdownButton<String>(
            key: const ValueKey('backup-cleanup-source'),
            value: _sourceId,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: AppTextTokens.body(context),
            items: [
              for (final source in _sources)
                DropdownMenuItem(
                  value: source.id,
                  child: Text(
                    source.isLocal
                        ? l10n.backupCleanupLocal
                        : source.displayName,
                  ),
                ),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) _loadPreview(value);
                  },
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: Text(
          [
            l10n.backupCleanupHint,
            l10n.backupCleanupRetention,
            l10n.backupCleanupCheckHint,
            if (_sourceId != null && _sourceId != 'local')
              l10n.backupCleanupCloudScopeHint,
          ].join('\n'),
          style: AppTextTokens.label(
            context,
          ).copyWith(color: AppTokens.textSecondary(context)),
        ),
      ),
      if (_busy && preview == null)
        const Padding(
          padding: EdgeInsets.all(AppDimens.p32),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_error != null)
        AppLoadError(message: _error, onRetry: () => _loadSources(_sourceId))
      else if (preview != null) ...[
        if (!preview.supportsDeletion)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: AppDimens.p8,
            ),
            child: Text(
              l10n.backupCleanupReadOnlyHint,
              style: AppTextTokens.label(context),
            ),
          ),
        if (!preview.hasCurrentBackup)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: AppDimens.p8,
            ),
            child: Text(
              l10n.backupCleanupNoCurrentHint,
              style: AppTextTokens.label(context),
            ),
          ),
        if (preview.entries.isEmpty) AppEmpty(text: l10n.backupCleanupEmpty),
      ],
    ];
    final files = _error == null
        ? preview?.entries ?? const <BackupCleanupEntry>[]
        : const <BackupCleanupEntry>[];
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.backupCleanupTitle,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.refresh,
                tooltip: l10n.commonRetry,
                onPressed: _busy ? null : () => _loadSources(_sourceId),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: headers.length + files.length + 1,
              itemBuilder: (context, index) {
                if (index < headers.length) {
                  return headers[index];
                }
                final fileIndex = index - headers.length;
                if (fileIndex < files.length) {
                  return _fileTile(files[fileIndex]);
                }
                return const SizedBox(height: AppDimens.p16);
              },
            ),
          ),
          AppEditorFooter(
            label: l10n.backupCleanupDeleteSelected(_selected.length),
            onPressed: _busy || _selected.isEmpty ? null : _deleteSelected,
            busy: _deleting,
          ),
        ],
      ),
    );
  }
}
