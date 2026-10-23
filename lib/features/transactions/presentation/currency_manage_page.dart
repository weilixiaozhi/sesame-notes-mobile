import 'package:sesame_notes/shared/presentation/currency_order.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/presentation/currency_names.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 管理展示币种页。
///
/// 设计意图:全量 146 个币种在各选择列表(汇率页、账本币种、记账币种、
/// 账本管理币种)里过长,用户在此勾选「常用子集」,勾选的币种才会出现在
/// 上述选择列表中。仅影响 UI 展示,不影响 API 拉取与交易数据。
///
/// - 账本币种(折算基准)始终锁定不可取消,行内显示锁图标与提示。
/// - 已有交易记录的币种允许自由隐藏:交易数据保留原币种码,随时可重新启用。
/// - 默认展示 [kCommonCurrencyCodes](13 个常用币种)。
class CurrencyManagePage extends ConsumerStatefulWidget {
  const CurrencyManagePage({super.key});

  @override
  ConsumerState<CurrencyManagePage> createState() => _CurrencyManagePageState();
}

class _CurrencyManagePageState extends ConsumerState<CurrencyManagePage> {
  // 币种筛选关键词:按 code(大写包含)或本地化名称(原文包含)匹配,
  // 复用各 picker 的过滤交互,空关键词展示全部。
  String _query = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    // 释放控制器避免内存泄漏
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 锁定基准 = 当前账本本位币(每账本一套可见集合,仅锁定自己的本位币)
    final base = ref.watch(currentLedgerCurrencyProvider);
    final visible = ref.watch(visibleCurrenciesProvider);
    final allCur = getCurrencies(context);

    // 排序:账本币种(当前账本本位币 base)常驻置顶 + 常用币种按系统语言排序
    // (与欢迎页一致) + 其余按地区原顺序。复用 orderCurrencies,与 picker 行为统一。
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final ordered = orderCurrenciesForLocale(
      allCur,
      locale,
      pinned: [base.toUpperCase()],
    );

    // 关键词过滤:与各 picker 一致(code 大写包含 / 名称原文包含)
    final filtered = ordered.where((c) {
      final q = _query.trim();
      if (q.isEmpty) return true;
      final uq = q.toUpperCase();
      return c.code.contains(uq) || c.name.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.currencyManageTitle, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p12,
                vertical: AppDimens.p8,
              ),
              children: [
                // 顶部统计:已选 N 个币种。实时跟随 visible 集合变化。
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p4,
                    vertical: AppDimens.p4,
                  ),
                  child: Text(
                    l10n.currencyManageCount(visible.length),
                    style: AppTextTokens.label(
                      context,
                    ).copyWith(color: AppTokens.textSecondary(context)),
                  ),
                ),
                const SizedBox(height: AppDimens.p4),
                // 搜索框:复用 ledgersSearchCurrency 文案与各 picker 交互
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(AppIcons.search),
                    hintText: l10n.ledgersSearchCurrency,
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              AppIcons.close,
                              size: AppDimens.icon20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: AppDimens.p8),
                if (filtered.isEmpty)
                  // 筛选无匹配:空状态提示
                  AppEmpty(
                    text: l10n.commonEmpty,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimens.p32,
                    ),
                  )
                else
                  // 币种列表:每行 币种符号 + 名称(code) + 右侧 Checkbox
                  // 账本币种行锁定:Checkbox 禁用 + 锁图标 + 提示文案
                  SectionCard(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (int i = 0; i < filtered.length; i++) ...[
                          if (i > 0)
                            AppTokens.cardDivider(
                              context,
                              indent: AppDimens.p12,
                              verticalGap: 0,
                              height: 1,
                              endIndent: AppDimens.p12,
                            ),
                          _CurrencyManageRow(
                            info: filtered[i],
                            // 本位币锁定按大小写不敏感比较,与 pinned 口径一致,
                            // 避免数据异常(小写/混合大小写)时基准币种行解锁。
                            isBase:
                                filtered[i].code.toUpperCase() ==
                                base.toUpperCase(),
                            isVisible: visible.contains(filtered[i].code),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: AppDimens.p16),
                // 底部说明:隐藏的币种不影响已有交易,随时可重新启用
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
                  child: Text(
                    l10n.currencyManageHint,
                    style: AppTextTokens.caption(context).copyWith(
                      color: AppTokens.textTertiary(context),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.p8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 单条币种管理行。
///
/// 账本本位币行(isBase=true):Checkbox 强制勾选且禁用,右侧显示锁图标与
/// 「账本本位币，不可隐藏」提示,点击不触发切换。
/// 普通币种行:点击整行切换勾选状态,通过 [toggleCurrencyVisibility] 持久化。
class _CurrencyManageRow extends ConsumerWidget {
  final CurrencyInfo info;
  final bool isBase;
  final bool isVisible;

  const _CurrencyManageRow({
    required this.info,
    required this.isBase,
    required this.isVisible,
  });

  /// 保存失败时维持已落盘选择，用户可再次点击同一币种重试。
  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      await toggleCurrencyVisibility(
        ref.read(applicationReaderProvider),
        info.code,
      );
    } catch (_) {
      // 应用层已记录脱敏异常与堆栈，此处仅负责用户反馈。
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return InkWell(
      // 本位币行不可点击切换(锁定),其余行点击切换可见性
      onTap: isBase ? null : () => _toggle(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p8,
        ),
        child: Row(
          children: [
            // 与币种选择弹窗、欢迎页币种列表同一布局：固定宽度符号列
            // (kCurrencySymbolColumnWidth)。币种符号长短不一（如 ¥ 与 HK$），
            // 若按内容自适应宽度，各行名称起始 x 会随符号宽度漂移，列表参差不齐。
            // 固定列宽后，名称列在所有行中对齐到同一 x 位置，UI 口径全局一致。
            currencySymbolColumn(
              info.code,
              style: AppTextTokens.title(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
            // 与弹窗 ListTile 的 horizontalTitleGap=16 保持一致，
            // 保证符号列到名称列的间距与各处选择列表相同。
            const SizedBox(width: AppDimens.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${info.name} (${info.code})',
                    style: AppTextTokens.title(
                      context,
                    ).copyWith(color: AppTokens.textPrimary(context)),
                  ),
                  if (isBase)
                    // 账本币种锁定提示:让用户明确为何该行不可取消
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimens.p4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.lock,
                            size: AppDimens.icon12,
                            color: AppTokens.textTertiary(context),
                          ),
                          const SizedBox(width: AppDimens.p4),
                          Text(
                            l10n.currencyManageBaseLocked,
                            style: AppTextTokens.caption(
                              context,
                            ).copyWith(color: AppTokens.textTertiary(context)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Checkbox:账本币种强制勾选且禁用;其余正常切换
            Checkbox(
              value: isBase ? true : isVisible,
              onChanged: isBase ? null : (_) => _toggle(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
