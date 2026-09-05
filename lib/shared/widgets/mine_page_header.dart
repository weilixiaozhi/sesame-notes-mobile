import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 我的页头部：按 local/authenticated 两种账号状态渲染。
///
/// 设计意图：
/// - 未登录：默认头像 + 单机芝麻仔（我）+ 本地使用·未登录 + 登录/注册主操作；
///   头像与昵称不可点击编辑，点击头像不进入预览；
/// - 已登录：云头像或默认头像 + 云昵称 + 芝麻号 + 进入箭头；点击整个头部
///   （含头像）进入个人资料，不提供独立的头像放大预览；
/// - 本地资料不可配置：本地身份固定展示默认头像与「单机芝麻仔」文案。
class MinePageHeader extends ConsumerWidget {
  const MinePageHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountStateProvider);
    if (state.isAuthenticated) {
      return const _AuthenticatedHeader();
    }
    return const _LocalHeader();
  }
}

/// 未登录头部：默认头像 + 单机芝麻仔 + 本地使用说明 + 登录/注册主操作。
class _LocalHeader extends StatelessWidget {
  const _LocalHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppDimens.p20),
          child: Column(
            children: [
              // 身份、说明与主操作保持在同一视觉层级，便于用户先确认当前状态再登录。
              Row(
                children: [
                  // 未登录恒显全局默认头像资产,与已登录头像同一渲染入口。
                  const SelfAvatar(size: 60),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.mineLocalSlogan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.strongTitle(context),
                        ),
                        const SizedBox(height: AppDimens.p4),
                        Text(
                          l10n.mineLocalSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.label(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.p12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p8,
                      ),
                    ),
                    onPressed: () => context.pushNamed(Routes.authLogin),
                    child: Text(l10n.mineLoginRegister),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.p16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.p12),
                decoration: BoxDecoration(
                  color: AppTokens.surfaceSelected(context),
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                ),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.info,
                      size: AppDimens.icon16,
                      color: AppTokens.primary(context),
                    ),
                    const SizedBox(width: AppDimens.p8),
                    Expanded(
                      child: Text(
                        l10n.mineLoginValue,
                        style: AppTextTokens.label(
                          context,
                        ).copyWith(color: AppTokens.primary(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 已登录头部：云头像（磁盘缓存，离线可用）或默认头像 + 云昵称 + 芝麻号 + 进入箭头；整卡可点击。
class _AuthenticatedHeader extends ConsumerWidget {
  const _AuthenticatedHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(accountStateProvider);
    final profile = state.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            onTap: () => context.pushNamed(Routes.profile),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.p20),
              child: Row(
                children: [
                  // 本人头像统一走 SelfAvatar:磁盘缓存离线可用,
                  // 未上传/下载失败回退全局默认头像资产 60×60。
                  const SelfAvatar(size: 60),
                  const SizedBox(width: AppDimens.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.displayName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.strongTitle(context),
                        ),
                        const SizedBox(height: AppDimens.p4),
                        Text(
                          profile?.sesameNumber != null
                              ? l10n.mineSesameNumber(profile!.sesameNumber!)
                              : '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.label(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.p16),
                  Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
