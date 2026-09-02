/// 第三方云备份配置页。
///
/// 设计意图：所有后端共用同一页面骨架，后端字段由 application 展示模型
/// 提供，文案由宿主 App 按 labelKey 解析；本页不枚举具体后端。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

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

/// 第三方备份配置页：按 [backend] 声明的字段渲染表单并保存激活。
class CloudBackupConfigPage extends ConsumerStatefulWidget {
  final CloudBackupBackendDisplay backend;

  const CloudBackupConfigPage({super.key, required this.backend});

  @override
  ConsumerState<CloudBackupConfigPage> createState() =>
      _CloudBackupConfigPageState();
}

class _CloudBackupConfigPageState extends ConsumerState<CloudBackupConfigPage> {
  final _formKey = GlobalKey<FormState>();

  /// 文本 / 数字 / 密码字段的编辑控制器（按字段 key 索引）。
  late final Map<String, TextEditingController> _controllers;

  /// 开关字段的当前值（按字段 key 索引）。
  late final Map<String, bool> _toggles;

  bool _saving = false;
  bool _loaded = false;

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
    _loadExisting();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 加载已保存配置回填表单（幂等，失败静默保持空表单）。
  Future<void> _loadExisting() async {
    try {
      final settings = await ref
          .read(cloudBackupActionsProvider)
          .loadSettings(widget.backend.id);
      if (settings == null || _loaded) return;
      setState(() {
        for (final field in widget.backend.fields) {
          final value = settings[field.key];
          if (value == null) continue;
          if (field.type == CloudBackupFieldType.boolean) {
            _toggles[field.key] = value == true;
          } else {
            _controllers[field.key]!.text = value.toString();
          }
        }
        _loaded = true;
      });
    } catch (error, stackTrace) {
      // 配置缺失/解析失败按空表单处理，不阻塞配置页使用。
      logger.error('CloudBackupConfig', '加载已有配置失败', error, stackTrace);
      if (mounted) setState(() => _loaded = true);
    }
  }

  /// 按当前表单构造配置；后端校验不通过返回 null（调用方提示必填缺失）。
  Map<String, dynamic>? _buildSettings() {
    final settings = <String, dynamic>{};
    for (final field in widget.backend.fields) {
      final value = switch (field.type) {
        CloudBackupFieldType.boolean => _toggles[field.key],
        CloudBackupFieldType.number => int.tryParse(
          _controllers[field.key]!.text.trim(),
        ),
        // 密码原样保留：首尾空格可能是有效字符，不能 trim。
        CloudBackupFieldType.secret => _orNull(_controllers[field.key]!.text),
        CloudBackupFieldType.text => _orNull(
          _controllers[field.key]!.text.trim(),
        ),
      };
      if (value != null) settings[field.key] = value;
    }
    return ref
            .read(cloudBackupActionsProvider)
            .isValid(widget.backend.id, settings)
        ? settings
        : null;
  }

  /// 空串视为未填写，避免把空值写进配置。
  static String? _orNull(String text) => text.isEmpty ? null : text;

  /// 测试连接：构建 provider 并做一次连通性探测（list 根路径）。
  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context);
    final settings = _buildSettings();
    if (settings == null) {
      showToast(context, l10n.cloudBackupRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(cloudBackupActionsProvider)
          .testConnection(widget.backend.id, settings);
      if (!mounted) return;
      showToast(context, l10n.cloudBackupTestOk);
    } catch (error, stackTrace) {
      logger.warning(
        'CloudBackupConfig',
        '云连接测试失败: ${widget.backend.id}',
        '$error\n$stackTrace',
      );
      if (!mounted) return;
      showToast(context, l10n.cloudBackupTestFailed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 保存并激活；必填缺失给提示，失败弹错误框。
  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final settings = _buildSettings();
    if (settings == null) {
      showToast(context, l10n.cloudBackupRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      await ref
          .read(cloudBackupActionsProvider)
          .saveAndActivate(widget.backend.id, settings);
      if (!mounted) return;
      showToast(context, l10n.cloudBackupSaved);
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      logger.error('CloudBackupConfig', '保存配置失败', error, stackTrace);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.commonFailed,
        message: l10n.commonOperationFailed,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.p12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: numeric ? TextInputType.number : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.cloudBackupConfigTitle, showBack: true),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.p16),
                      child: Column(
                        children: [
                          for (final field in widget.backend.fields)
                            if (field.type == CloudBackupFieldType.boolean)
                              SwitchListTile(
                                title: Text(
                                  cloudBackupFieldLabel(l10n, field.labelKey),
                                ),
                                value: _toggles[field.key] ?? false,
                                onChanged: (v) =>
                                    setState(() => _toggles[field.key] = v),
                              )
                            else
                              _field(
                                cloudBackupFieldLabel(l10n, field.labelKey),
                                _controllers[field.key]!,
                                obscure: field.isSecret,
                                numeric:
                                    field.type == CloudBackupFieldType.number,
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _saving ? null : _testConnection,
                      child: Text(l10n.cloudBackupTestConnection),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(l10n.cloudBackupSave),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
