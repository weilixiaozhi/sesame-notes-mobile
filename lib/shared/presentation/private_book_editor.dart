import 'package:sesame_notes/shared/application/private_book_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/models/private_book.dart';
import '../../data/models/sync_issue.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/dimens.dart';
import '../../utils/text_validation.dart';
import '../providers/account_state_provider.dart';
import '../providers/current_private_book_provider.dart';
import '../providers/data_lifecycle_provider.dart';
import '../widgets/widgets.dart';
import '../widgets/app_form_section.dart';

/// 本子表单只维护一份身份、重试、确认与忙碌状态；仓储差异由实际操作提供。
class PrivateBookEditor extends ConsumerStatefulWidget {
  const PrivateBookEditor({
    super.key,
    this.book,
    required this.actions,
    required this.title,
    required this.nameLabel,
    required this.selection,
    required this.deleteMessage,
    this.extraField,
  });
  final PrivateBook? book;
  final PrivateBookActions actions;
  final String title, nameLabel;
  final CurrentPrivateBookNotifier Function() selection;
  final String Function(int count) deleteMessage;

  /// 创建时的附加字段（如备忘录本子类型）；编辑既有本子时由调用方传 null。
  final Widget? extraField;
  @override
  ConsumerState<PrivateBookEditor> createState() => _PrivateBookEditorState();
}

/// 保存与归属管理互斥，进度提示只描述当前实际执行的操作。
enum _BookEditorOperation { save, ownership }

class _PrivateBookEditorState extends ConsumerState<PrivateBookEditor> {
  final _name = TextEditingController();
  final _form = GlobalKey<FormState>();
  late final String _id;
  late final String? _account;
  late final int _generation;
  PrivateBook? _created;
  _BookEditorOperation? _operation;

  /// 所有操作共用互斥状态，保存按钮只在保存时展示进度。
  bool get _busy => _operation != null;

  @override
  void initState() {
    super.initState();
    _id = widget.book?.id ?? const Uuid().v4();
    _account = ref.read(currentAccountIdProvider);
    _generation = ref.read(authIdentityGenerationProvider);
    _name.text = widget.book?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 会话校验由应用用例统一执行，页面只保留打开时的身份快照。
  void _checkSession() => widget.actions.verifySession(_account, _generation);

  /// 获取经过账号和绑定复核的当前本子快照。
  Future<PrivateBookSnapshot> _snapshot() => widget.actions.snapshot(
    id: _id,
    accountId: _account,
    generation: _generation,
    expected: widget.book ?? _created,
  );

  /// 统一校验会话、释放互斥状态，并为失败操作记录完整诊断信息。
  Future<void> _run(
    Future<void> Function() action, {
    required _BookEditorOperation operation,
  }) async {
    if (_busy) return;
    setState(() => _operation = operation);
    try {
      _checkSession();
      await action();
    } catch (error, stackTrace) {
      logger.error(
        'PrivateBookEditor',
        '本子操作失败：${operation.name}',
        error,
        stackTrace,
      );
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _operation = null);
    }
  }

  /// 提交表单后只处理选择与返回，事务和创建重试由用例负责。
  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    await _run(() async {
      // 一次提交固定业务类型和选本入口，异步回执不跟随父组件后续配置变化。
      final actions = widget.actions;
      final creating = widget.book == null;
      final selection = creating ? widget.selection() : null;
      final expected = widget.book ?? _created;
      final saved = await actions.save(
        id: _id,
        name: _name.text,
        accountId: _account,
        generation: _generation,
        expected: expected,
      );
      if (creating) {
        _created = saved;
        await selection!.select(_id);
      }
      actions.verifySession(_account, _generation);
      if (mounted) Navigator.of(context).pop(_id);
    }, operation: _BookEditorOperation.save);
  }

  /// 归属操作统一执行壳：二次确认 → 落盘未保存名称 → 执行 → 成功提示 / 返回。
  ///
  /// 与账本编辑页完全同一套逻辑：移动到云端 / 移动到本地会改变本子归属，
  /// 编辑页持有的快照随即过期，成功后必须返回列表；复制到本地不改变云端原件，
  /// 快照仍然有效，页面继续保留。
  Future<void> _action(String action) => _run(() async {
    final target = SyncTarget(widget.actions.targetType, _id);
    // 归属操作按数据库当前值生成结果：名称非法时先中止，避免搬走半成品名称。
    if (action != 'delete' && !_form.currentState!.validate()) return;
    final snapshot = await _snapshot();
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final title = switch (action) {
      'move_to_cloud' => l.ledgersActionMoveToCloud,
      'move_to_local' => l.ledgersActionMoveToLocal,
      'copy_to_local' => l.ledgersActionCopyToLocal,
      _ => l.commonDelete,
    };
    final confirmed = await AppDialog.confirmAsync(
      context,
      title: title,
      message: switch (action) {
        'move_to_cloud' => l.privateBookMoveToCloudMessage(snapshot.book.name),
        'move_to_local' => l.privateBookMoveToLocalMessage(snapshot.book.name),
        'copy_to_local' => l.privateBookCopyToLocalMessage(snapshot.book.name),
        _ => widget.deleteMessage(snapshot.count),
      },
      errorMessage: (_) => l.commonOperationFailed,
      onConfirm: () async {
        _checkSession();
        if (action == 'delete') {
          await ref
              .read(dataLifecycleProvider)
              .deleteTarget(
                target,
                expectedCount: snapshot.count,
                validate: () async {
                  final current = await _snapshot();
                  if (current.count != snapshot.count) {
                    throw StateError('BOOK_CONTENT_CHANGED');
                  }
                  return null;
                },
              );
          return;
        }
        // 先落盘表单里尚未保存的名称，否则会出现「界面上是新名字、
        // 搬过去还是旧名字」的假状态。
        await _persistName(snapshot.book);
        _checkSession();
        final lifecycle = ref.read(dataLifecycleProvider);
        if (action == 'move_to_cloud') {
          await lifecycle.moveToCloud(target);
          return;
        }
        final selected = await widget.selection().currentSelection();
        _checkSession();
        final id = action == 'move_to_local'
            ? await lifecycle.moveToLocal(target)
            : await lifecycle.copyToLocal(target);
        _checkSession();
        // 被搬走的原本是当前选中本时，选择切到发布的本地副本。
        if (action == 'move_to_local' && selected == _id) {
          await widget.selection().select(id);
        }
      },
    );
    if (!confirmed || !mounted) return;
    final successText = switch (action) {
      'move_to_cloud' => l.ledgersMoveToCloudSuccess,
      'move_to_local' => l.ledgersMoveToLocalSuccess,
      'copy_to_local' => l.ledgersCopyToLocalSuccess,
      _ => null,
    };
    if (successText != null) showToast(context, successText);
    if (action != 'copy_to_local') Navigator.of(context).pop();
  }, operation: _BookEditorOperation.ownership);

  /// 右上角菜单：归属操作与账本编辑页逐项对齐。
  ///
  /// 账本的三条归属路径（移动到云端 / 移动到本地 / 复制到本地）在四个业务域
  /// 共用同一套规则：入口按本子归属展示，未登录或云端快照不可搬迁时保留入口
  /// 并置灰，让用户始终能看到本子具备的迁移能力。
  Widget _buildMoreMenu(AppLocalizations l, PrivateBook book) {
    final moveLabel = book.isCloud
        ? l.ledgersActionMoveToLocal
        : l.ledgersActionMoveToCloud;
    // 云端操作要求已登录且快照完整：未下载完成、绑定失效、待本地删除的云端本
    // 无法生成可靠副本，只置灰不放行。
    final ready =
        _account != null &&
        (!book.isCloud ||
            (book.isComplete && !book.isStale && !book.pendingLocalDelete));
    return AppPopupMenu(
      enabled: !_busy,
      onSelected: _action,
      items: [
        ready
            ? AppMenuItem.action(
                value: book.isCloud ? 'move_to_local' : 'move_to_cloud',
                label: moveLabel,
              )
            : AppMenuItem.tip(label: moveLabel),
        if (book.isCloud) ...[
          ready
              ? AppMenuItem.action(
                  value: 'copy_to_local',
                  label: l.ledgersActionCopyToLocal,
                )
              : AppMenuItem.tip(label: l.ledgersActionCopyToLocal),
        ],
        AppMenuItem.action(
          value: 'delete',
          label: l.commonDelete,
          isDanger: true,
        ),
      ],
    );
  }

  /// 归属操作前提交有效的新名称，未修改的名称不产生写入。
  Future<void> _persistName(PrivateBook book) async {
    final name = normalizeName(_name.text);
    if (name == book.name) return;
    await widget.actions.save(
      id: _id,
      name: name,
      accountId: _account,
      generation: _generation,
      expected: book,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context), book = widget.book;
    final valid =
        ref.watch(currentAccountIdProvider) == _account &&
        ref.watch(authIdentityGenerationProvider) == _generation;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: AbsorbPointer(
          absorbing: _busy,
          child: ExcludeFocus(
            excluding: _busy,
            child: Column(
              children: [
                PrimaryHeader(
                  title: book?.name ?? widget.title,
                  showBack: true,
                  actions: [if (book != null && valid) _buildMoreMenu(l, book)],
                ),
                Expanded(
                  child: Form(
                    key: _form,
                    child: ListView(
                      padding: const EdgeInsets.all(AppDimens.p16),
                      children: [
                        ?widget.extraField,
                        AppFormSection(
                          title: widget.nameLabel,
                          child: TextFormField(
                            controller: _name,
                            enabled: valid && !_busy,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: widget.nameLabel,
                            ),
                            validator: (value) => isValidName(value ?? '')
                                ? null
                                : l.commonNameInvalid(maxNameLength),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppEditorFooter(
                  label: l.commonSave,
                  busy: _operation == _BookEditorOperation.save,
                  onPressed: valid && !_busy ? _save : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
