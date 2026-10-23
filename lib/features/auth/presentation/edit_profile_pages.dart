import 'package:sesame_notes/utils/text_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/settings/presentation/widgets/settings_selection.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 编辑昵称页：计数器使用公共名称上限，保存成功后把更新后的 Profile 返回给上一页。
class EditNicknamePage extends ConsumerStatefulWidget {
  const EditNicknamePage({super.key});

  @override
  ConsumerState<EditNicknamePage> createState() => _EditNicknamePageState();
}

class _EditNicknamePageState extends ConsumerState<EditNicknamePage> {
  late final TextEditingController _controller;
  bool busy = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(accountStateProvider).profile?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => errorText = l10n.editNameEmpty);
      return;
    }
    if (!isValidName(name)) {
      setState(() => errorText = l10n.commonNameInvalid(maxNameLength));
      return;
    }
    setState(() {
      busy = true;
      errorText = null;
    });
    try {
      final updated = await ref
          .read(authActionsProvider)
          .updateDisplayName(normalizeName(name));
      if (!mounted) return;
      showToast(context, l10n.editNameSaved);
      Navigator.of(context).pop(updated);
    } catch (error, stackTrace) {
      logger.error('EditNickname', '保存昵称失败', error, stackTrace);
      if (!mounted) return;
      setState(() {
        errorText = switch (mapApiError(error)) {
          ApiErrorKind.displayNameInvalid => l10n.commonNameInvalid(
            maxNameLength,
          ),
          ApiErrorKind.network => l10n.authErrorNetworkIssue,
          ApiErrorKind.server => l10n.authErrorServer,
          _ => l10n.editNameSaveFailed,
        };
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.editNameTitle,
            showBack: true,
            actions: [
              HeaderTextAction(
                label: l10n.editNameSave,
                onPressed: busy ? null : _save,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p20,
                AppDimens.p20 + AppDimens.p4,
                AppDimens.p20,
                AppDimens.p20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: AppDimens.authFieldHeight,
                    child: TextField(
                      controller: _controller,
                      maxLength: maxNameLength,
                      onChanged: (_) {
                        if (errorText != null) {
                          setState(() => errorText = null);
                        }
                      },
                      decoration: InputDecoration(
                        fillColor: AppTokens.surfaceInput(context),
                        counterText: '',
                        suffixIconConstraints: const BoxConstraints(
                          minHeight: AppDimens.authFieldHeight,
                          minWidth: 0,
                        ),
                        suffixIcon: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _controller,
                          builder: (context, value, _) {
                            final length = value.text.characters.length;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$length / $maxNameLength',
                                  style: AppTextTokens.label(context).copyWith(
                                    color: AppTokens.textTertiary(context),
                                  ),
                                ),
                                if (value.text.isNotEmpty)
                                  IconButton(
                                    tooltip: l10n.editNameClear,
                                    onPressed: busy
                                        ? null
                                        : () {
                                            _controller.clear();
                                            if (errorText != null) {
                                              setState(() => errorText = null);
                                            }
                                          },
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.p8,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: AppDimens.p36,
                                      minHeight: AppDimens.authFieldHeight,
                                    ),
                                    icon: Container(
                                      width: AppDimens.icon20,
                                      height: AppDimens.icon20,
                                      decoration: BoxDecoration(
                                        color: AppTokens.iconTertiary(context),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        AppIcons.close,
                                        size: AppDimens.icon12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p4,
                    ),
                    child: Text(
                      l10n.editNameHint,
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.textTertiary(context)),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: AppDimens.p8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p4,
                      ),
                      child: Text(
                        errorText!,
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(color: AppTokens.error(context)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 性别设置页：三个选项单选，保存成功后返回更新后的 Profile。
class EditGenderPage extends ConsumerStatefulWidget {
  const EditGenderPage({super.key});

  @override
  ConsumerState<EditGenderPage> createState() => _EditGenderPageState();
}

class _EditGenderPageState extends ConsumerState<EditGenderPage> {
  late String _selected;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(accountStateProvider).profile?.gender ?? 'UNSPECIFIED';
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => busy = true);
    try {
      final updated = await ref
          .read(authActionsProvider)
          .updateGender(_selected);
      if (!mounted) return;
      showToast(context, l10n.editGenderSaved);
      Navigator.of(context).pop(updated);
    } catch (error, stackTrace) {
      logger.error('EditGender', '保存性别失败', error, stackTrace);
      if (!mounted) return;
      showToast(context, l10n.editNameSaveFailed);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 与语言、深色模式共用公共单选页样式，只有保存动作与隐私提示是本页专有。
    return SettingsSelection<String>(
      title: l10n.editGenderTitle,
      options: {
        'UNSPECIFIED': l10n.profileGenderUnset,
        'MALE': l10n.profileGenderMale,
        'FEMALE': l10n.profileGenderFemale,
      },
      selectedValue: _selected,
      onChanged: (value) {
        if (busy) return;
        setState(() => _selected = value);
      },
      actions: [
        HeaderTextAction(
          label: l10n.editNameSave,
          onPressed: busy ? null : _save,
        ),
      ],
      footer: Text(
        l10n.editGenderPrivacyHint,
        style: AppTextTokens.label(
          context,
        ).copyWith(color: AppTokens.textTertiary(context)),
      ),
    );
  }
}
