import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 正式默认本人头像（随客户端包分发的静态资产，与 PLACEHOLDER 的人形占位不同）。
const String kDefaultAvatarAsset = 'assets/Default avatar.png';

/// 我的页头部：按 local/authenticated 两种账号状态渲染。
///
/// 设计意图：
/// - 未登录：默认头像 + 单机芝麻仔（我）+ 本地使用·未登录 + 登录/注册主操作；
///   头像与昵称不可点击编辑，点击头像不进入预览；
/// - 已登录：云头像或默认头像 + 云昵称 + 芝麻号 + 进入箭头；点击整个头部
///   （含头像）进入个人资料，不再有独立的「点击头像放大预览」逻辑；
/// - 本地资料不是一个可配置 Profile：旧的本地昵称问候语与可编辑头像逻辑退役。
class MinePageHeader extends ConsumerWidget {
  const MinePageHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountStateProvider);
    if (state.isAuthenticated) {
      return _AuthenticatedHeader(profileAvatarUrl: state.profile?.avatarUrl);
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(kDefaultAvatarAsset),
                  ),
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

/// 已登录头部：云头像或默认头像 + 云昵称 + 芝麻号 + 进入箭头；整卡可点击。
class _AuthenticatedHeader extends ConsumerWidget {
  final String? profileAvatarUrl;

  const _AuthenticatedHeader({this.profileAvatarUrl});

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
                  // 云头像或默认头像（60×60）；整张卡片共用个人资料入口。
                  CircleAvatar(
                    radius: 30,
                    foregroundImage: profileAvatarUrl != null
                        ? NetworkImage(profileAvatarUrl!)
                        : null,
                    backgroundImage: const AssetImage(kDefaultAvatarAsset),
                  ),
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
