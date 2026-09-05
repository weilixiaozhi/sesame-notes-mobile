import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/account_logout_flow.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 个人资料页：基本资料（头像/昵称/性别）与账号与安全（芝麻号/手机号/登录密码）。
///
/// 设计意图：芝麻号与手机号只读（不提供复制）；退出登录是页面底部独立的
/// 危险操作按钮，带说明文字，点击弹出确认对话框；不设独立「账号与安全」页。
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    unawaited(_refreshProfile());
  }

  /// 进入资料页时拉取本人最新资料；失败保留现有缓存展示。
  Future<void> _refreshProfile() async {
    try {
      await ref.read(authActionsProvider).refreshProfile();
    } catch (_) {
      // AuthActions 已记录错误，后台刷新失败不打断资料页使用。
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(accountStateProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.profileTitle, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p16,
                AppDimens.p20,
                AppDimens.p16,
                AppDimens.p20,
              ),
              children: [
                // 头像作为页面身份焦点独立居中，避免与可编辑资料行争抢层级。
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppDimens.radius44),
                    onTap: () => context.pushNamed(Routes.profileAvatar),
                    child: SizedBox(
                      width: AppDimens.p40 * 2,
                      height: AppDimens.p40 * 2,
                      child: Stack(
                        children: [
                          // 本人头像统一走 SelfAvatar:磁盘缓存离线可用,
                          // 与我的页/成员管理/AA 分摊页同一套头像逻辑。
                          Positioned.fill(
                            child: SelfAvatar(size: AppDimens.p40 * 2),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: AppDimens.icon28,
                              height: AppDimens.icon28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTokens.primary(context),
                                border: Border.all(
                                  color: AppTokens.scaffoldBackground(context),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                AppIcons.edit,
                                size: AppDimens.icon16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.p20),
                _buildSection(
                  context,
                  title: l10n.profileBasicInfo,
                  child: Column(
                    children: [
                      _buildRow(
                        context,
                        title: l10n.profileNickname,
                        value: profile?.displayName ?? '',
                        onTap: () => context.pushNamed(Routes.profileName),
                      ),
                      AppTokens.cardDivider(context),
                      _buildRow(
                        context,
                        title: l10n.profileGender,
                        value: _genderLabel(l10n, profile?.gender),
                        onTap: () => context.pushNamed(Routes.profileGender),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p20),
                _buildSection(
                  context,
                  title: l10n.profileAccountInfo,
                  child: Column(
                    children: [
                      _buildRow(
                        context,
                        title: l10n.profileSesameNumber,
                        value: profile?.sesameNumber ?? '',
                      ),
                      AppTokens.cardDivider(context),
                      _buildRow(
                        context,
                        title: l10n.profilePhone,
                        value: profile?.phone ?? profile?.phoneMasked ?? '',
                      ),
                      AppTokens.cardDivider(context),
                      _buildRow(
                        context,
                        title: l10n.profileChangePassword,
                        onTap: () => context.pushNamed(Routes.accountPassword),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p20),
                // 退出登录：独立于任何分区的危险操作按钮
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTokens.error(context),
                    side: BorderSide(color: AppTokens.error(context)),
                  ),
                  onPressed: () async {
                    final loggedOut = await confirmAccountLogout(context, ref);
                    if (loggedOut && context.mounted) context.pop();
                  },
                  child: Text(l10n.profileLogout),
                ),
                const SizedBox(height: AppDimens.p8),
                Text(
                  l10n.profileLogoutHint,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(color: AppTokens.textTertiary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建带统一标题与卡片样式的资料分组。
  /// 分组标题走全局 SectionTitle（主题色条 + 主题色标题），
  /// 水平内缩 16 与下方卡片外边距对齐。
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: title,
          padding: const EdgeInsets.only(
            left: AppDimens.p16,
            right: AppDimens.p16,
            bottom: AppDimens.p8,
          ),
        ),
        SectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }

  /// 构建资料行：标题靠左、值与可编辑箭头贴卡片右缘，保持信息扫描方向一致。
  Widget _buildRow(
    BuildContext context, {
    required String title,
    String? value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p16,
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textPrimary(context)),
            ),
            // 中间弹性区把值与箭头推到卡片右缘；值过长时收缩省略
            Expanded(
              child: value == null
                  ? const SizedBox.shrink()
                  : Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTokens.label(context),
                      ),
                    ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: AppDimens.p8),
              Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon20,
                color: AppTokens.iconTertiary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _genderLabel(AppLocalizations l10n, String? gender) {
    switch (gender) {
      case 'MALE':
        return l10n.profileGenderMale;
      case 'FEMALE':
        return l10n.profileGenderFemale;
      default:
        return l10n.profileGenderUnset;
    }
  }
}
