import 'package:sesame_notes/shared/presentation/currency_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/presentation/currency_names.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/currency_flag.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';

/// 币种选择 bottom sheet(搜索 + 币种符号 + 汇率 + 选中勾)。返回选中的 code,取消返回 null。
///
/// 汇率页、账本设置与记账弹窗共用币种选择、搜索及汇率展示。
/// [rateBase] 传入(大写 ISO)时,每行右侧展示「1 该币种 ≈ x rateBase」的汇率
/// (弹窗内拉一次全量,缺失显示占位)。
/// [showRateAsBaseLabel] 为 true 时(记账页调用),仅账本币种自身行使用符号化展示
/// 「账本币种 · ¥1.00」;其他币种的汇率换算统一走 formatExchangeRate,
/// 输出「(1 USD = 7.24 CNY)」(ISO 代号 + 括号),不使用货币符号。
/// [visibleCurrencies] 传 null = 全量 146 个币种(首次引导页用);
/// 传非空集合 = 仅展示集合内币种。当前选中值(selected)与 rateBase(账本本位币)
/// 始终强制保留——避免当前值被过滤后看不到选中态,导致用户困惑。
/// [compact] 紧凑模式:内容文字 12px、弹窗总高 320(默认 440)。
/// [pinSelected] 选中值是否常驻置顶(默认置顶,汇率页/记账弹窗语义);
/// 传 false 时选中值保持语言顺序原位置(欢迎页选账本币种)。
Future<String?> showCurrencyPickerSheet(
  BuildContext context, {
  required String selected,
  // 标题必传:不同入口语义不同(选交易币种/选账本本位币/管理可见集合),
  // 由调用方给准确文案,本组件不内置默认标题
  required String title,
  String? rateBase,
  // 子 sheet 挂载 navigator(false = 就近 / nested);默认 true 使用主 navigator
  bool useRootNavigator = true,
  // 子 sheet 遮罩色;记账页内调用传透明以不显示遮罩
  Color? barrierColor,
  // 记账页内调用传 true,符号化展示汇率
  bool showRateAsBaseLabel = false,
  // 可见币种集合(大写 ISO);null=全量,非空=仅展示集合内 + 当前值兜底
  Set<String>? visibleCurrencies,
  // 紧凑模式:内容文字 12px、总高 320
  bool compact = false,
  // 选中值常驻置顶开关
  bool pinSelected = true,
}) {
  final current = selected.toUpperCase();
  // 搜索草稿属于本次弹层，会随主题更新保留到用户关闭选择器。
  String query = '';
  return showAppSheet<String>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierColor: barrierColor,
    child: Builder(
      builder: (bctx) {
        return StatefulBuilder(
          builder: (sctx, setSheetState) {
            // 排序:账本币种(rateBase)/ 选中值(selected)常驻置顶 + 常用币种按系统语言
            // 排序(与欢迎页一致) + 其余按地区原顺序。复用 orderCurrencies 保证多入口一致。
            final allCur = getCurrencies(bctx);
            // 可见性过滤:visibleCurrencies 非空时仅保留集合内币种;
            // 当前选中值与 rateBase 强制保留(兜底,避免当前值被隐藏后看不到选中态)。
            final rateBaseUp = rateBase?.toUpperCase();
            final source = visibleCurrencies == null
                ? allCur
                : allCur
                      .where(
                        (c) =>
                            visibleCurrencies.contains(c.code) ||
                            c.code == current ||
                            c.code == rateBaseUp,
                      )
                      .toList();
            final locale = WidgetsBinding.instance.platformDispatcher.locale;
            // 置顶集合:账本币种(rateBase)优先,其次当前选中值(selected),去重。
            // 两者无论是否常用币种都常驻置顶(账本币种永远第一位)。
            // pinSelected=false 时(欢迎页选账本币种)选中值不置顶,保持语言顺序原位置。
            final pins = <String>[];
            if (rateBaseUp != null) pins.add(rateBaseUp);
            if (pinSelected && !pins.contains(current)) pins.add(current);
            final ordered = orderCurrenciesForLocale(
              source,
              locale,
              pinned: pins,
            );
            final filtered = ordered.where((c) {
              final q = query.trim();
              if (q.isEmpty) return true;
              final uq = q.toUpperCase();
              return c.code.contains(uq) || c.name.contains(q);
            }).toList();

            return SizedBox(
              // 紧凑模式:总高 320,默认 440
              height: compact ? 320 : 440,
              child: AppSheet(
                title: title,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(AppIcons.search),
                        hintText: AppLocalizations.of(
                          bctx,
                        ).ledgersSearchCurrency,
                      ),
                      onChanged: (v) => setSheetState(() => query = v),
                    ),
                    const SizedBox(height: AppDimens.p8),
                    Expanded(
                      // 汇率展示:rateBase 传入时用 Consumer 拿全量汇率;否则空 map。
                      child: Consumer(
                        builder: (cctx, ref, _) {
                          final rates = rateBase == null
                              ? const <String, double>{}
                              : (ref
                                        .watch(
                                          currencyPickerRatesProvider(
                                            rateBase.toUpperCase(),
                                          ),
                                        )
                                        .value ??
                                    const <String, double>{});
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final c = filtered[i];
                              final sel = c.code == current;
                              // 汇率行:1 该币种 ≈ x rateBase(base 自身/缺失不显示)
                              // 记账页(showRateAsBaseLabel=true)符号化展示
                              String? rateText;
                              if (rateBase != null) {
                                final baseCode = rateBase.toUpperCase();
                                final baseSym = getCurrencySymbol(baseCode);
                                if (c.code == baseCode) {
                                  // 账本币种自身
                                  if (showRateAsBaseLabel) {
                                    // 「账本币种 · ¥1.00」(仅自身行用符号,汇率换算统一走 ISO)
                                    rateText =
                                        '${AppLocalizations.of(cctx).txLedgerBaseCurrency} · $baseSym${(1.0).toStringAsFixed(2)}';
                                  }
                                } else {
                                  final r = rates[c.code];
                                  if (r != null) {
                                    // 汇率换算文案统一来源:(1 USD = 7.24 CNY)
                                    rateText = formatExchangeRate(
                                      c.code,
                                      baseCode,
                                      r.toString(),
                                    );
                                  }
                                }
                              }
                              final tile = AppRadioTile(
                                title: '${c.name} (${c.code})',
                                selected: sel,
                                compact: compact,
                                leading: showRateAsBaseLabel
                                    ? Container(
                                        width: AppDimens.icon40,
                                        height: AppDimens.icon40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppTokens.surfaceSecondary(
                                            cctx,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            AppDimens.p4,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              getCurrencySymbol(c.code),
                                              maxLines: 1,
                                              softWrap: false,
                                              style: AppTextTokens.title(cctx)
                                                  .copyWith(
                                                    color: AppTokens.primary(
                                                      cctx,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : currencySymbolColumn(
                                        c.code,
                                        style:
                                            (compact
                                                    ? AppTextTokens.label(
                                                        context,
                                                      )
                                                    : AppTextTokens.title(
                                                        context,
                                                      ))
                                                .copyWith(
                                                  color:
                                                      AppTokens.textSecondary(
                                                        cctx,
                                                      ),
                                                ),
                                      ),
                                subtitle: rateText == null
                                    ? null
                                    : Text(
                                        rateText,
                                        style: AppTextTokens.caption(context)
                                            .copyWith(
                                              color: AppTokens.textTertiary(
                                                cctx,
                                              ),
                                            ),
                                      ),
                                onTap: () => Navigator.pop(bctx, c.code),
                              );
                              // 记账编辑器的币种选项采用主题化卡片，搜索、汇率与排序规则保持共用。
                              if (!showRateAsBaseLabel) return tile;
                              return SectionCard(
                                margin: const EdgeInsets.only(
                                  bottom: AppDimens.p8,
                                ),
                                padding: EdgeInsets.zero,
                                showShadow: false,
                                selected: sel,
                                color: sel
                                    ? AppTokens.domainAccentBackground(cctx)
                                    : AppTokens.surface(cctx),
                                child: tile,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
