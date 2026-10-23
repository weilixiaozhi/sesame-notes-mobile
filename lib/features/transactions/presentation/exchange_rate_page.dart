import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'widgets/rate_input_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/presentation/currency_names.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_currency_change.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/currency_picker_sheet.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 汇率管理页(账本维度化后):
/// - 基准 = 当前账本本位币(ledger.currency),切账本自动换组
/// - 自动拉取(24h 节流,单币种内部 no-op)+ 手动编辑覆盖
/// - 基准行点击 = 切当前账本本位币(确认/重算/同步走统一公共函数)
/// 方向约定全链统一:rate 字符串 = 「1 quote = rate base」。
class ExchangeRatePage extends ConsumerStatefulWidget {
  const ExchangeRatePage({super.key});

  @override
  ConsumerState<ExchangeRatePage> createState() => _ExchangeRatePageState();
}

class _ExchangeRatePageState extends ConsumerState<ExchangeRatePage> {
  // 缓存上一次成功加载的汇率数据。
  // 目的:刷新期间 effectiveRatesForLedgerProvider 短暂 loading 时用缓存承接列表,
  // 避免全屏 CircularProgressIndicator 导致的闪屏。
  // 基准币种(base)变化时 _lastBase != base 自动失效,走首次加载态。
  String? _lastBase;
  Map<String, EffectiveRate>? _lastRates;

  @override
  void initState() {
    super.initState();
    // 进页静默拉取:24h 节流 + 单币种 no-op,内部自判,不阻塞 UI。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      refreshExchangeRates(read: ref.read(applicationReaderProvider));
    });
  }

  /// 强制刷新汇率，使用统一最小展示时长并反馈刷新结果。
  Future<void> _onRefresh() async {
    final l10n = AppLocalizations.of(context);
    try {
      final ok = await ensureMinimumRefreshDuration(
        () => refreshExchangeRates(
          read: ref.read(applicationReaderProvider),
          force: true,
        ),
      );
      if (!mounted) return;
      showToast(context, ok ? l10n.rateRefreshSuccess : l10n.rateRefreshFailed);
    } catch (e, st) {
      logger.error('ExchangeRate', '下拉刷新汇率失败', e, st);
      if (!mounted) return;
      showToast(context, l10n.rateRefreshFailed);
    }
  }

  /// 按当前账本展示汇率信息，卡片统一承担内容留白和整卡点击。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    // 基准 = 当前账本本位币(折算基准唯一来源);切账本自动换组
    final base = ref.watch(currentLedgerCurrencyProvider);
    final ratesAsync = ref.watch(effectiveRatesForLedgerProvider);
    final currentLedger = ref.watch(currentLedgerDisplayProvider).value;

    // 缓存:有数据时存入 _lastRates,base 与缓存 base 一致时刷新期间用缓存承接,
    // 避免 effectiveRatesForLedgerProvider 短暂 loading 触发全屏 spinner 闪屏。
    if (ratesAsync.hasValue && ratesAsync.value != null) {
      _lastBase = base;
      _lastRates = Map<String, EffectiveRate>.from(ratesAsync.value!);
    }
    final bool hasCache = _lastBase == base && _lastRates != null;
    // refresh 期间 use cache;无缓存或 base 变了才走 provider raw value
    final rates = hasCache
        ? _lastRates!
        : (ratesAsync.value ?? const <String, EffectiveRate>{});

    // 外币 = 用户可见币种集合 − 基准币种(「管理展示币种」页勾选子集,
    // 仅影响 UI 展示;API 仍全量拉取存储,隐藏币种随时可重新启用)。
    // 按 kCurrencyCodes 原顺序过滤,保持与币种选择弹窗一致的列表顺序。
    final visible = ref.watch(visibleCurrenciesProvider);
    final allQuotes = kCurrencyCodes
        .where(
          (c) => visible.contains(c.toUpperCase()) && c.toUpperCase() != base,
        )
        .toList();
    // 汇率列表直接使用可见币种集合,不做搜索过滤。
    final quotes = allQuotes;

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.exchangeRatePageTitle, showBack: true),
          // 首次加载(无缓存):弱化 loading,仅 24x24 小圈 + stroke 2px,
          // 比默认 36px 全屏 spinner 轻量,减少视觉突兀感。
          if (ratesAsync.isLoading && !hasCache)
            const Expanded(
              child: Center(
                child: SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            )
          // 首次加载出错(无缓存):显示错误信息与重试按钮。
          // 有缓存时即使出错也走正常内容区(用旧数据兜底),不阻断浏览。
          else if (ratesAsync.hasError && !hasCache)
            Expanded(
              child: AppLoadError(
                message: l10n.analyticsLoadFailed,
                retryLabel: l10n.analyticsRetry,
                onRetry: _onRefresh,
              ),
            )
          // 有数据或缓存时保留内容，使用统一的下拉刷新指示器。
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  // 内容不足一屏时也允许下拉刷新。
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                    vertical: AppDimens.p8,
                  ),
                  children: [
                    // 顶部说明模块(账本币种含义与手动汇率用法)
                    SectionCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                AppIcons.info,
                                size: AppDimens.icon20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: AppDimens.p8),
                              Text(
                                l10n.exchangeRateInfoTitle,
                                style: AppTextTokens.strongTitle(context)
                                    .copyWith(
                                      color: AppTokens.textPrimary(context),
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimens.p8),
                          Text(
                            l10n.exchangeRateInfoMessage,
                            style: AppTextTokens.body(context).copyWith(
                              color: AppTokens.textSecondary(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.p8),
                    // 作用域标注(按账本维度):
                    // 汇率组 = 当前账本视角,避免用户误以为基准仍是全局的。
                    // 无账本时隐藏。
                    if (currentLedger != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimens.p4,
                          bottom: AppDimens.p4,
                        ),
                        child: Text(
                          l10n.exchangeRateCurrentLedger(currentLedger.name),
                          style: AppTextTokens.label(
                            context,
                          ).copyWith(color: AppTokens.textTertiary(context)),
                        ),
                      ),
                    // 1. 基准币种(账本本位币;无账本时置灰,点击仅提示先创建账本)
                    SectionCard(
                      margin: EdgeInsets.zero,
                      onTap: () => _pickBaseCurrency(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p12,
                        vertical: AppDimens.p20,
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.ledgerBaseCurrencyLabel,
                            style: AppTextTokens.title(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                          ),
                          const Spacer(),
                          // 全局统一「ISO + (符号)」展示
                          currencyFlagLabel(
                            base,
                            textStyle: AppTextTokens.body(context).copyWith(
                              color: currentLedger == null
                                  ? AppTokens.textTertiary(context)
                                  : AppTokens.textSecondary(context),
                            ),
                          ),
                          SizedBox(width: AppDimens.p4),
                          Icon(
                            AppIcons.chevronRight,
                            size: AppDimens.icon16,
                            color: AppTokens.iconTertiary(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.p8),
                    // 1.5 币种管理入口:跳转「管理展示币种」页,
                    // 右侧实时显示已选币种数,让用户一眼知道当前过滤范围。
                    SectionCard(
                      margin: EdgeInsets.zero,
                      onTap: () => context.pushNamed(Routes.currencyManage),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p12,
                        vertical: AppDimens.p20,
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.currencyManageEntry,
                            style: AppTextTokens.title(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                          ),
                          const Spacer(),
                          Text(
                            l10n.currencyManageCount(visible.length),
                            style: AppTextTokens.body(
                              context,
                            ).copyWith(color: AppTokens.textSecondary(context)),
                          ),
                          SizedBox(width: AppDimens.p4),
                          Icon(
                            AppIcons.chevronRight,
                            size: AppDimens.icon16,
                            color: AppTokens.iconTertiary(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimens.p12),

                    // 2. 汇率列表
                    SectionCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: quotes.isEmpty
                          // 筛选无匹配:展示空状态提示,避免空白列表
                          ? AppEmpty(
                              text: l10n.commonEmpty,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.p32,
                              ),
                            )
                          : Column(
                              children: [
                                for (int i = 0; i < quotes.length; i++) ...[
                                  if (i > 0)
                                    AppTokens.cardDivider(
                                      context,
                                      indent: AppDimens.p12,
                                      verticalGap: 0,
                                      height: 1,
                                      endIndent: AppDimens.p12,
                                    ),
                                  _RateRow(
                                    quote: quotes[i],
                                    base: base,
                                    eff: rates[quotes[i]],
                                    primary: primary,
                                    onEdit: () => _editRate(
                                      context,
                                      quotes[i],
                                      base,
                                      rates[quotes[i]],
                                    ),
                                    onReset: () => _resetRate(quotes[i], base),
                                  ),
                                ],
                              ],
                            ),
                    ),

                    SizedBox(height: AppDimens.p16),
                    // 3. 免责声明
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDimens.p4),
                      child: Text(
                        l10n.rateDisclaimer,
                        style: AppTextTokens.caption(context).copyWith(
                          color: AppTokens.textTertiary(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimens.p8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 基准币种选择底部弹窗(可见币种子集 + 搜索)。
  /// 选中 = 切当前账本本位币,确认弹窗/拉汇率/重算/刷新/同步全收敛在
  /// 公共函数 applyLedgerCurrencyChange(与账本编辑入口共用)。
  /// 无账本时不可切换，并提示先创建账本。
  Future<void> _pickBaseCurrency(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ledger = ref.read(currentLedgerDisplayProvider).value;
    if (ledger == null) {
      showToast(context, l10n.homeBaseCurrencyNeedLedger);
      return;
    }
    try {
      final picked = await showCurrencyPickerSheet(
        context,
        selected: ledger.currency.toUpperCase(),
        title: l10n.ledgerBaseCurrencyLabel,
        showRateAsBaseLabel: true,
        // 与账本编辑页一致:账本币种选择不展示汇率换算行(rateBase 不传)
        visibleCurrencies: ref.read(visibleCurrenciesProvider),
      );
      if (picked == null || !context.mounted) return;
      await applyLedgerCurrencyChange(
        context,
        ledgerId: ledger.id,
        newCurrency: picked,
      );
    } catch (error, stackTrace) {
      logger.error(
        'ExchangeRate',
        '切换账本本位币失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (context.mounted) showToast(context, l10n.commonOperationFailed);
    }
  }

  /// 编辑某币种的手动汇率。
  Future<void> _editRate(
    BuildContext context,
    String quote,
    String base,
    EffectiveRate? eff,
  ) async {
    // 弹窗自持 TextEditingController(State.dispose 在路由完全移除后才被调用)。
    // 不要在 await showDialog 返回后立刻 dispose —— 退场动画期间 TextField
    // 仍引用 controller,会 use-after-dispose 红屏。
    final result = await showDialog<RateInputResult>(
      context: context,
      builder: (_) => RateInputDialog(
        quote: quote,
        base: base,
        allowReset: eff?.manual ?? false,
        // 预填:手动值回填原始字符串(保留用户精度);自动值用 formatRate6 展示
        // (6 位有效,编辑后会被新输入覆盖,截断无妨);无汇率则留空。
        initialText: eff == null
            ? ''
            : (eff.manual ? eff.rate : formatRate6(eff.rate)),
      ),
    );
    if (result == null || !mounted) return; // 取消/遮罩关闭

    final actions = ref.read(transactionActionsProvider);
    try {
      if (result.reset) {
        await actions.removeRateOverride(base: base, quote: quote);
      } else {
        // rate 字符串原样存用户输入(trim),不二次格式化。
        await actions.setRateOverride(
          base: base,
          quote: quote,
          rate: result.rate,
        );
      }
    } catch (e, st) {
      // 写库失败不能静默:提示用户并保持页面原状态,避免与数据库不一致。
      logger.error(
        'ExchangeRate',
        '保存汇率失败 base=$base quote=$quote reset=${result.reset}',
        e,
        st,
      );
      if (!context.mounted) return;
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
      return;
    }
    if (mounted) ref.read(rateRefreshTickProvider.notifier).tick();
  }

  /// 恢复某币种为自动汇率，并更新页面可见状态。
  /// 与编辑弹窗内 reset 分支逻辑一致,此处为列表行「恢复自动」文字链外显。
  Future<void> _resetRate(String quote, String base) async {
    try {
      await ref
          .read(transactionActionsProvider)
          .removeRateOverride(base: base, quote: quote);
    } catch (e, st) {
      // 恢复自动汇率写库失败时提示用户,不静默。
      logger.error('ExchangeRate', '恢复自动汇率失败 base=$base quote=$quote', e, st);
      // State.context 使用 State.mounted 守卫,满足 use_build_context_synchronously。
      if (!mounted) return;
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
      return;
    }
    if (mounted) ref.read(rateRefreshTickProvider.notifier).tick();
  }
}

/// 单条汇率行。
/// 状态文案中性;右侧汇率值下方右对齐常驻「编辑」文字链;仅「手动」汇率
/// 才并列「恢复自动」。
class _RateRow extends ConsumerWidget {
  final String quote;
  final String base;
  final EffectiveRate? eff;
  final Color primary;
  final VoidCallback onEdit;
  final VoidCallback onReset;

  const _RateRow({
    required this.quote,
    required this.base,
    required this.eff,
    required this.primary,
    required this.onEdit,
    required this.onReset,
  });

  /// rateDate 距今 > 7 天?(rateDate 形如 "2026-06-10")
  bool _isStale(String? rateDate) {
    if (rateDate == null) return false;
    final d = DateTime.tryParse(rateDate);
    if (d == null) return false;
    // 服务端可能返回带时区的日期字符串:先取年月日构造本地零点再比较,
    // 避免 UTC 日期在东八区被误判为"昨天"导致 7 天过期判断差 8 小时。
    final dateOnly = DateTime(d.year, d.month, d.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(dateOnly) > const Duration(days: 7);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mainName = getCurrencyName(quote, context);
    final bool isManual = eff?.manual == true;

    // 中性状态文案(非按钮样式,仅作标识)
    Widget status;
    if (eff == null) {
      status = Text(
        l10n.rateNotFetched,
        style: AppTextTokens.label(
          context,
        ).copyWith(color: AppTokens.textTertiary(context)),
      );
    } else if (isManual) {
      status = Text(
        l10n.rateSourceManual,
        style: AppTextTokens.label(
          context,
        ).copyWith(color: AppTokens.textSecondary(context)),
      );
    } else {
      final stale = _isStale(eff!.rateDate);
      status = Text(
        '${l10n.rateSourceAuto} · ${l10n.rateUpdatedAt(eff!.rateDate ?? '')}',
        style: AppTextTokens.label(context).copyWith(
          color: stale
              ? AppTokens.warning(context)
              : AppTokens.textTertiary(context),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.p12,
        vertical: AppDimens.p12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左:币种名 + 码 / 状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        mainName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTokens.title(
                          context,
                        ).copyWith(color: AppTokens.textPrimary(context)),
                      ),
                    ),
                    SizedBox(width: AppDimens.p4),
                    Text(
                      quote,
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.textTertiary(context)),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.p4),
                // 状态文案 + 「恢复自动」文字链（仅手动态显示）。
                // 放在状态文案右侧、左对齐，与右侧编辑按钮分离，避免误触。
                // isManual=true 时 status 为「手动」（短文本），不会与链接溢出。
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: status),
                    if (isManual) ...[
                      SizedBox(width: AppDimens.p8),
                      // 「恢复自动」文字链使用 primary 色，让用户明确感知到
                      // 它是可点击的操作入口。
                      // 纯动作文字链（恢复自动），无选中态，按统一原则补涟漪反馈
                      TextButton(
                        onPressed: onReset,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.p8,
                            vertical: AppDimens.p8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.rateResetToAuto,
                          style: AppTextTokens.label(
                            context,
                          ).copyWith(color: primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimens.p8),
          // 右:汇率值 + 下方编辑文字链（右对齐）
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 汇率换算值
              Text(
                // 统一汇率换算文案:(1 USD = 7.24 CNY),未获取时回退占位符
                eff == null
                    ? kRatePlaceholder
                    : formatExchangeRate(quote, base, eff!.rate),
                style: AppTextTokens.label(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: eff == null
                      ? AppTokens.textTertiary(context)
                      : AppTokens.textPrimary(context),
                ),
              ),
              SizedBox(height: AppDimens.p4),
              // 编辑文字链常驻右对齐。「恢复自动」位于左侧手动文案旁边，
              // 不与编辑链并列，避免两个操作入口紧挨导致误触。
              // 纯动作文字链（编辑汇率），无选中态，按统一原则补涟漪反馈
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p8,
                    vertical: AppDimens.p8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.rateEditLabel,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600, color: primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
