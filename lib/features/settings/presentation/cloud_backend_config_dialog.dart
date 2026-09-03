/// 第三方云备份配置弹窗（注册表驱动）。
///
/// 与 Spitout cloud_config_dialogs.dart 同职责：配置以**弹窗**承载（本仓库
/// 曾改为独立配置页，现恢复弹窗形态）；但字段模型沿用本仓库 adapter 声明的
/// [CloudBackupFieldDisplay]，不硬编码任何后端字段，新增后端零改动。
///
/// 弹窗返回值约定：
/// - `Map<String, dynamic>`：用户提交的设置（键与 adapter 声明一致）；
/// - '__DELETE__'：用户点击标题栏清除图标（仅 [canDelete] 时出现）；
/// - null：取消。
library;

import 'package:flutter/material.dart';

import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 删除哨兵：用户在弹窗标题栏点击清除图标时经路由 context pop 返回。
const String cloudConfigDeleteSentinel = '__DELETE__';

/// 把 adapter 声明的 labelKey 解析成本地化文案。
///
/// adapter 不持有文案（多语言归宿主 App 所有），字段因此只带键名；未登记的
/// 键原样回退，保证新增后端字段不会让页面崩溃。
String cloudBackupFieldLabel(AppLocalizations l10n, String labelKey) =>
    switch (labelKey) {
      'cloudBackupUrlLabel' => l10n.cloudBackupUrlLabel,
      'cloudBackupAnonKeyLabel' => l10n.cloudBackupAnonKeyLabel,
      'cloudBackupBucketLabel' => l10n.cloudBackupBucketLabel,
      'cloudBackupAccountLabel' => l10n.cloudBackupAccountLabel,
      'cloudBackupUsernameLabel' => l10n.cloudBackupUsernameLabel,
      'cloudBackupPasswordLabel' => l10n.cloudBackupPasswordLabel,
      'cloudBackupRemotePathLabel' => l10n.cloudBackupRemotePathLabel,
      'cloudBackupEndpointLabel' => l10n.cloudBackupEndpointLabel,
      'cloudBackupRegionLabel' => l10n.cloudBackupRegionLabel,
      'cloudBackupAccessKeyLabel' => l10n.cloudBackupAccessKeyLabel,
      'cloudBackupSecretKeyLabel' => l10n.cloudBackupSecretKeyLabel,
      'cloudBackupPortLabel' => l10n.cloudBackupPortLabel,
      'cloudBackupSslLabel' => l10n.cloudBackupSslLabel,
      _ => labelKey,
    };

/// 第三方备份配置弹窗：按 [backend] 声明的字段渲染表单。
class CloudBackendConfigDialog extends StatefulWidget {
  final CloudBackupBackendDisplay backend;

  /// 已保存配置（回填表单）；null = 新建。
  final Map<String, dynamic>? initialSettings;

  /// 已存在配置时标题栏显示清除图标。
  final bool canDelete;

  const CloudBackendConfigDialog({
    super.key,
    required this.backend,
    this.initialSettings,
    this.canDelete = false,
  });

  @override
  State<CloudBackendConfigDialog> createState() =>
      _CloudBackendConfigDialogState();
}

class _CloudBackendConfigDialogState extends State<CloudBackendConfigDialog> {
  /// 文本 / 数字 / 密码字段的编辑控制器（按字段 key 索引）。
  late final Map<String, TextEditingController> _controllers;

  /// 开关字段的当前值（按字段 key 索引）。
  late final Map<String, bool> _toggles;

  /// 内联校验错误（按字段 key 索引）：保存时为空则在对应字段下方显示弱提示。
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in widget.backend.fields)
        if (field.type != CloudBackupFieldType.boolean)
          field.key: TextEditingController(),
    };
    _toggles = {
      for (final field in widget.backend.fields)
        if (field.type == CloudBackupFieldType.boolean)
          field.key: field.defaultValue == true,
    };
    _fillExisting();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 回填已保存配置（失败静默保持空表单）。
  void _fillExisting() {
    final settings = widget.initialSettings ?? const {};
    for (final field in widget.backend.fields) {
      final value = settings[field.key];
      if (value == null) continue;
      if (field.type == CloudBackupFieldType.boolean) {
        _toggles[field.key] = value == true;
      } else {
        _controllers[field.key]!.text = value.toString();
      }
    }
  }

  /// 按当前表单构造设置；必填/数字校验不通过返回 null（错误已内联展示）。
  Map<String, dynamic>? _buildSettings() {
    final l10n = AppLocalizations.of(context);
    final settings = <String, dynamic>{};
    _errors.clear();
    for (final field in widget.backend.fields) {
      switch (field.type) {
        case CloudBackupFieldType.boolean:
          settings[field.key] = _toggles[field.key] ?? false;
        case CloudBackupFieldType.number:
          final text = _controllers[field.key]!.text.trim();
          if (text.isEmpty) {
            if (field.isRequired) {
              _errors[field.key] = l10n.cloudConfigInvalidMessage;
            }
            break;
          }
          final parsed = int.tryParse(text);
          if (parsed == null) {
            // 端口等数字字段非空但解析失败：内联提示，不静默丢弃。
            _errors[field.key] = l10n.cloudConfigInvalidMessage;
          } else {
            settings[field.key] = parsed;
          }
        case CloudBackupFieldType.secret:
        case CloudBackupFieldType.text:
          final text = _controllers[field.key]!.text.trim();
          if (text.isEmpty && field.isRequired) {
            _errors[field.key] = l10n.cloudConfigInvalidMessage;
          }
          if (text.isNotEmpty) settings[field.key] = text;
      }
    }
    return _errors.isEmpty ? settings : null;
  }

  /// 配置弹窗标题：按后端映射既有文案，未登记的后端回退展示名。
  String _titleOf() {
    final l10n = AppLocalizations.of(context);
    return switch (widget.backend.id) {
      'supabase' => l10n.cloudConfigureSupabaseTitle,
      'webdav' => l10n.cloudConfigureWebdavTitle,
      's3' => l10n.cloudConfigureS3Title,
      _ => widget.backend.displayName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheet(
      title: _titleOf(),
      // 删除图标常驻标题栏右侧 trailing。
      trailing: widget.canDelete
          ? IconButton(
              icon: const Icon(AppIcons.delete, size: AppDimens.icon22),
              tooltip: l10n.cloudClearConfig,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 32),
              padding: EdgeInsets.zero,
              // 用弹窗自身路由 context 直接 pop 删除哨兵。
              onPressed: () =>
                  Navigator.of(context).pop(cloudConfigDeleteSentinel),
            )
          : null,
      showGrabHandle: false,
      // ignore: sort_child_properties_last
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in widget.backend.fields) ...[
              if (field.type == CloudBackupFieldType.boolean)
                SwitchListTile(
                  title: Text(cloudBackupFieldLabel(l10n, field.labelKey)),
                  value: _toggles[field.key] ?? false,
                  onChanged: (v) => setState(() => _toggles[field.key] = v),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.p12),
                  child: TextField(
                    controller: _controllers[field.key],
                    obscureText: field.isSecret,
                    keyboardType: field.type == CloudBackupFieldType.number
                        ? TextInputType.number
                        : null,
                    decoration: InputDecoration(
                      labelText: cloudBackupFieldLabel(l10n, field.labelKey),
                      errorText: _errors[field.key],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      footer: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.commonCancel),
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                // 内联校验：必填/数字不通过时仅在字段下方显示弱提示，
                // 不切换弹窗、不丢失已填内容。
                final settings = _buildSettings();
                if (settings == null) {
                  setState(() {});
                  return;
                }
                Navigator.of(context).pop(settings);
              },
              child: Text(l10n.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}
