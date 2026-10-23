import 'package:sesame_notes/domain/recurring_schedule.dart'
    show recurringLocation;
import 'package:timezone/timezone.dart' as tz;
import 'widgets/recurring_time_zone_picker.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/app_date_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_selector.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/currency_picker_sheet.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/transactions/domain/recurring_transaction_rules.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class RecurringTransactionEditPage extends ConsumerStatefulWidget {
  final RecurringTransactionDisplay? recurring;
  final String? ledgerId;

  /// 新账本尚未落库时传入币种；保存返回草稿，交由账本统一提交。
  final String? draftCurrency;

  const RecurringTransactionEditPage({
    super.key,
    this.recurring,
    this.ledgerId,
    this.draftCurrency,
  });

  @override
  ConsumerState<RecurringTransactionEditPage> createState() =>
      _RecurringTransactionEditPageState();
}

class _RecurringTransactionEditPageState
    extends ConsumerState<RecurringTransactionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late RecurringFrequency _frequency;
  late int _interval;
  late DateTime _startDate;
  DateTime? _endDate;
  int? _dayOfMonth;
  int? _dayOfWeek;
  int? _monthOfYear;
  late String _timeZone;
  CategoryDisplay? _selectedCategory;
  String? _currencyCode;
  late bool _enabled;
  String? _selectedLedgerId; // 选中的账本ID
  bool _saving = false; // 保存进行中,防止连点重复建单/更新
  bool _deleting = false; // 删除进行中,防止连点

  bool get _isEditing => widget.recurring != null;
  bool get _isDraft => widget.draftCurrency != null;
  bool get _timeZoneLocked => widget.recurring?.lastGeneratedDate != null;
  bool get _validTimeZone =>
      _timeZone == 'UTC' ||
      tz.timeZoneDatabase.locations.containsKey(_timeZone);

  @override
  void initState() {
    super.initState();
    // 时区表尚未载入时初始化；已完成的原生本机时区选择保持不变。
    recurringLocation('UTC');
    if (_isEditing) {
      _frequency = RecurringFrequency.fromString(widget.recurring!.frequency);
      _interval = widget.recurring!.interval;
      _startDate = recurringDateOnly(widget.recurring!.startDate);
      _endDate = widget.recurring!.endDate == null
          ? null
          : recurringDateOnly(widget.recurring!.endDate!);
      _dayOfMonth = widget.recurring!.dayOfMonth ?? _startDate.day;
      _dayOfWeek = widget.recurring!.dayOfWeek ?? _startDate.weekday;
      _monthOfYear = widget.recurring!.monthOfYear ?? _startDate.month;
      _timeZone = widget.recurring!.timeZone;
      _enabled = widget.recurring!.enabled;
      _currencyCode = widget.recurring!.currencyCode;
      _selectedLedgerId = widget.recurring!.ledgerId;
      _amountController.text = widget.recurring!.amount;
      _noteController.text = widget.recurring!.note ?? '';
      _loadCategory();
    } else {
      _frequency = RecurringFrequency.monthly;
      _interval = 1;
      _timeZone = tz.local.name;
      final today = tz.TZDateTime.now(tz.local);
      _startDate = recurringDateOnly(today);
      _dayOfWeek = _startDate.weekday;
      _monthOfYear = _startDate.month;
      // 月频「每月几号」默认跟开始日期同一天，避免新建后首笔落在别的日子。
      _dayOfMonth = defaultRecurringDayOfMonth(_startDate);
      _enabled = true;
      // 优先使用管理页传入的账本，避免误记到首页当前账本。
      _selectedLedgerId = _isDraft
          ? null
          : widget.ledgerId ?? ref.read(currentLedgerIdProvider);
      _currencyCode = widget.draftCurrency;
    }

    // 监听金额输入变化，更新按钮状态
    _amountController.addListener(() {
      setState(() {});
    });
  }

  /// 周期记录从自己的账本目录回填分类，账号和共享所有者之间相互隔离。
  Future<void> _loadCategory() async {
    if (_isEditing && widget.recurring!.categoryId != null) {
      try {
        final category = await ref
            .read(categoryActionsProvider)
            .getById(
              widget.recurring!.categoryId!,
              ledgerId: widget.recurring!.ledgerId,
            );
        // 加载期间页面可能已销毁,且分类被删除时返回 null 无需回填。
        if (!mounted || category == null) return;
        setState(() {
          _selectedCategory = category;
        });
      } catch (e, st) {
        logger.warning('周期账单编辑', '加载分类失败', '$e\n$st');
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // 原账本与目标账本任一归档，都需要先恢复账本才能继续编辑。
    final ledgerIds = {widget.recurring?.ledgerId, _selectedLedgerId}.nonNulls;
    final archived = ledgerIds
        .map((id) => ref.watch(ledgerByIdProvider(id)).value?.archivedAt)
        .any((archivedAt) => archivedAt != null);

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: _isEditing
                ? l10n.recurringTransactionEdit
                : l10n.recurringTransactionAdd,
            showBack: true,
            actions: _isEditing && !archived
                ? [
                    AppPopupMenu(
                      enabled: !_deleting && !_saving,
                      items: [
                        AppMenuItem.action(
                          value: 'delete',
                          label: l10n.commonDelete,
                          icon: AppIcons.delete,
                          isDanger: true,
                        ),
                      ],
                      onSelected: (_) => _deleteRecurringTransaction(),
                    ),
                  ]
                : null,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [
                  SectionTitle(
                    title: l10n.recurringTransactionEnabled,
                    trailing: Transform.scale(
                      scale: AppDimens.compactSwitchScale,
                      transformHitTests: false,
                      child: Semantics(
                        label: l10n.recurringTransactionEnabled,
                        child: Switch.adaptive(
                          value: _enabled,
                          onChanged: archived
                              ? null
                              : (value) => setState(() => _enabled = value),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),

                  // 所属账本由管理页固定，分类沿用迁移网格。
                  AppFormSection(
                    title: l10n.categoryParentCategoryTitle,
                    child: _buildCategorySelector(l10n),
                  ),

                  // 金额
                  AppFormSection(
                    title: l10n.importFieldAmount,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: l10n.importFieldAmount,
                      ),
                      inputFormatters: [
                        // 与 Web 一致保留十位小数精度，拒绝科学计数法和负数。
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) =>
                              isValidRecurringAmountInput(newValue.text)
                              ? newValue
                              : oldValue,
                        ),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.commonError;
                        }
                        if (normalizeRecurringAmount(value) == null) {
                          return l10n.recurringTransactionAmountPrecision;
                        }
                        return null;
                      },
                    ),
                  ),

                  AppFormSection(
                    title: l10n.importFieldCurrency,
                    child: _buildCurrencySelector(l10n),
                  ),

                  // 频率
                  AppFormSection(
                    title: l10n.recurringTransactionFrequency,
                    child: _buildFrequencySelector(l10n),
                  ),

                  // 间隔
                  AppFormSection(
                    title: l10n.recurringTransactionInterval,
                    child: _buildIntervalSelector(l10n),
                  ),

                  if (_frequency == RecurringFrequency.weekly)
                    AppFormSection(
                      title: l10n.recurringTransactionDayOfWeek,
                      child: _buildDayOfWeekSelector(l10n),
                    ),
                  if (_frequency == RecurringFrequency.yearly)
                    AppFormSection(
                      title: l10n.recurringTransactionMonthOfYear,
                      child: _buildMonthOfYearSelector(l10n),
                    ),
                  if (_frequency == RecurringFrequency.monthly ||
                      _frequency == RecurringFrequency.yearly)
                    AppFormSection(
                      title: l10n.recurringTransactionDayOfMonth,
                      child: _buildDayOfMonthSelector(l10n),
                    ),

                  AppFormSection(
                    title: l10n.recurringTransactionTimeZone,
                    child: AppSelectionField(
                      title: _validTimeZone
                          ? _timeZone
                          : l10n.recurringTransactionTimeZoneInvalid,
                      subtitle: _timeZoneLocked
                          ? l10n.recurringTransactionTimeZoneLocked
                          : l10n.recurringTransactionTimeZoneHint,
                      enabled: !_timeZoneLocked && !archived && !_saving,
                      onTap: _timeZoneLocked || archived || _saving
                          ? null
                          : _selectTimeZone,
                    ),
                  ),
                  AppFormSection(
                    child: AppDateRangeFields(
                      start: _buildDateField(
                        label: l10n.recurringTransactionStartDate,
                        date: _startDate,
                        onTap: () => _selectDate(context, true),
                      ),
                      end: _buildDateField(
                        label: l10n.recurringTransactionEndDate,
                        date: _endDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ),

                  AppFormSection(
                    title: l10n.importFieldNote,
                    child: TextFormField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: l10n.commonNoteHint,
                      ),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!archived)
            AppEditorFooter(
              label: l10n.commonSave,
              busy: _saving,
              onPressed: _isFormValid() ? _saveRecurringTransaction : null,
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return AppSelectionField(
      title: _selectedCategory == null
          ? l10n.categorySelectParentHint
          : CategoryUtils.getDisplayName(_selectedCategory!.name, context),
      isPlaceholder: _selectedCategory == null,
      onTap: _selectCategory,
    );
  }

  Widget _buildCurrencySelector(AppLocalizations l10n) {
    final currency =
        _currencyCode ??
        (_selectedLedgerId == null || _selectedLedgerId!.isEmpty
            ? null
            : ref
                  .watch(ledgerByIdProvider(_selectedLedgerId!))
                  .value
                  ?.currency);
    return AppSelectionField(
      onTap: currency == null
          ? null
          : () async {
              await prepareForOverlay();
              if (!mounted) return;
              final picked = await showCurrencyPickerSheet(
                context,
                selected: currency,
                title: l10n.txCurrencyPickerTitle,
                visibleCurrencies: ref.read(visibleCurrenciesProvider),
              );
              if (picked != null && mounted) {
                setState(() => _currencyCode = picked);
              }
            },
      title: currency == null
          ? l10n.importFieldCurrency
          : '$currency (${getCurrencySymbol(currency)})',
    );
  }

  bool _isFormValid() {
    // 保存使用精确十进制，不把 Web 高精度金额舍入为分。
    if (!_validTimeZone ||
        _interval < 1 ||
        _interval > 10000 ||
        normalizeRecurringAmount(_amountController.text) == null) {
      return false;
    }

    // 检查账本
    if (!_isDraft &&
        (_selectedLedgerId == null || _selectedLedgerId!.isEmpty)) {
      return false;
    }

    // 检查分类
    if (_selectedCategory == null) {
      return false;
    }

    return true;
  }

  Widget _buildFrequencySelector(AppLocalizations l10n) {
    String frequencyLabel;
    switch (_frequency) {
      case RecurringFrequency.daily:
        frequencyLabel = l10n.recurringTransactionDaily;
        break;
      case RecurringFrequency.weekly:
        frequencyLabel = l10n.recurringTransactionWeekly;
        break;
      case RecurringFrequency.monthly:
        frequencyLabel = l10n.recurringTransactionMonthly;
        break;
      case RecurringFrequency.yearly:
        frequencyLabel = l10n.recurringTransactionYearly;
        break;
    }

    return AppSelectionField(
      onTap: () async {
        final result = await showWheelPicker<RecurringFrequency>(
          context,
          initial: _frequency,
          items: RecurringFrequency.values,
          labelBuilder: (freq) {
            switch (freq) {
              case RecurringFrequency.daily:
                return l10n.recurringTransactionDaily;
              case RecurringFrequency.weekly:
                return l10n.recurringTransactionWeekly;
              case RecurringFrequency.monthly:
                return l10n.recurringTransactionMonthly;
              case RecurringFrequency.yearly:
                return l10n.recurringTransactionYearly;
            }
          },
          title: l10n.recurringTransactionFrequency,
        );

        if (result != null && mounted) {
          setState(() {
            _frequency = result;
          });
        }
      },
      title: frequencyLabel,
    );
  }

  Widget _buildIntervalSelector(AppLocalizations l10n) {
    String intervalLabel;
    switch (_frequency) {
      case RecurringFrequency.daily:
        intervalLabel = l10n.recurringTransactionEveryNDays(_interval);
        break;
      case RecurringFrequency.weekly:
        intervalLabel = l10n.recurringTransactionEveryNWeeks(_interval);
        break;
      case RecurringFrequency.monthly:
        intervalLabel = l10n.recurringTransactionEveryNMonths(_interval);
        break;
      case RecurringFrequency.yearly:
        intervalLabel = l10n.recurringTransactionEveryNYears(_interval);
        break;
    }

    return TextFormField(
      initialValue: _interval.toString(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(
        labelText: l10n.recurringTransactionInterval,
        helperText: _interval >= 1 && _interval <= 10000
            ? intervalLabel
            : l10n.recurringTransactionIntervalInvalid,
      ),
      validator: (value) {
        final parsed = int.tryParse(value ?? '');
        return parsed == null || parsed < 1 || parsed > 10000
            ? l10n.recurringTransactionIntervalInvalid
            : null;
      },
      onChanged: (value) =>
          setState(() => _interval = int.tryParse(value) ?? 0),
    );
  }

  Widget _buildDayOfMonthSelector(AppLocalizations l10n) {
    return AppSelectionField(
      onTap: () async {
        final result = await showWheelPicker<int>(
          context,
          initial: _dayOfMonth ?? 1,
          items: List.generate(31, (index) => index + 1),
          labelBuilder: (day) => '$day',
          title: l10n.recurringTransactionDayOfMonth,
        );

        if (result != null && mounted) {
          setState(() {
            _dayOfMonth = result;
          });
        }
      },
      title: '${_dayOfMonth ?? 1}',
    );
  }

  /// 星期和月份独立于开始日期，编辑 Web 已有规则时不得丢失。
  Widget _buildDayOfWeekSelector(AppLocalizations l10n) => AppSelectionField(
    title: DateFormat.EEEE(
      l10n.localeName,
    ).format(DateTime(2026, 1, 4 + (_dayOfWeek ?? 1))),
    onTap: () async {
      final result = await showWheelPicker<int>(
        context,
        initial: _dayOfWeek ?? 1,
        items: List.generate(7, (index) => index + 1),
        labelBuilder: (day) =>
            DateFormat.EEEE(l10n.localeName).format(DateTime(2026, 1, 4 + day)),
        title: l10n.recurringTransactionDayOfWeek,
      );
      if (result != null && mounted) setState(() => _dayOfWeek = result);
    },
  );

  /// 年频同时保留指定月份和月内日，月末由统一生成协议夹取。
  Widget _buildMonthOfYearSelector(AppLocalizations l10n) => AppSelectionField(
    title: DateFormat.MMMM(
      l10n.localeName,
    ).format(DateTime(2026, _monthOfYear ?? 1)),
    onTap: () async {
      final result = await showWheelPicker<int>(
        context,
        initial: _monthOfYear ?? 1,
        items: List.generate(12, (index) => index + 1),
        labelBuilder: (month) =>
            DateFormat.MMMM(l10n.localeName).format(DateTime(2026, month)),
        title: l10n.recurringTransactionMonthOfYear,
      );
      if (result != null && mounted) setState(() => _monthOfYear = result);
    },
  );

  /// 只提供实际已载入的 IANA 时区；不把未知本机时区推测成固定偏移。
  Future<void> _selectTimeZone() async {
    if (_timeZoneLocked) return;
    await prepareForOverlay();
    if (!mounted) return;
    final result = await showRecurringTimeZonePicker(
      context,
      selected: _timeZone,
    );
    if (result != null && mounted) setState(() => _timeZone = result);
  }

  /// 起止日期复用阶段记录输入，结束日可独立清除。
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return AppDateField(
      label: label,
      stacked: true,
      onTap: onTap,
      valueText: date != null
          ? DateFormat.yMd().format(date)
          : AppLocalizations.of(context).recurringTransactionNoEndDate,
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    // 协议 1 从明确的开始日补齐；历史开始日期合法，结束日不能早于开始日。
    final minDate = isStartDate ? DateTime.utc(1000) : _startDate;
    var initial = isStartDate ? _startDate : (_endDate ?? _startDate);
    if (initial.isBefore(minDate)) initial = minDate;

    final date = await showWheelDatePicker(
      context,
      initial: DateTime(initial.year, initial.month, initial.day),
      minDate: DateTime(minDate.year, minDate.month, minDate.day),
      maxDate: DateTime(9999, 12, 31),
      title: isStartDate
          ? AppLocalizations.of(context).recurringTransactionStartDate
          : AppLocalizations.of(context).recurringTransactionEndDate,
      onPresent: isStartDate ? null : () => setState(() => _endDate = null),
      initialPresent: !isStartDate && _endDate == null,
      presentLabel: AppLocalizations.of(context).recurringTransactionNoEndDate,
    );

    if (date != null) {
      if (!context.mounted) return;
      final selectedDate = recurringDateOnly(date);
      // 先设结束日、再改开始日时,新开始日可能晚于结束日,这里阻断,
      // 保证区间始终合法(start <= end)。
      if (isStartDate && _endDate != null && selectedDate.isAfter(_endDate!)) {
        showToast(
          context,
          AppLocalizations.of(context).recurringTransactionEndBeforeStart,
        );
        return;
      }
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Future<void> _selectCategory() async {
    try {
      await prepareForOverlay();
      if (!mounted) return;
      // 周期账单允许挂到二级分类（选择器不限一级）。
      final categories = await ref
          .read(categoryActionsProvider)
          .filterForRecurringPicker(ledgerId: _selectedLedgerId);
      if (!mounted) return;
      final selected = await showCategoryGridSelector(
        context,
        availableCategories: [
          for (final category in categories)
            (category: category, transactionCount: 0),
        ],
        initialSelection: _selectedCategory?.id,
        title: AppLocalizations.of(context).categorySelectParentTitle,
        showTransactionCount: false,
      );
      if (selected != null && mounted) {
        setState(
          () => _selectedCategory = categories.firstWhere(
            (category) => category.id == selected,
          ),
        );
      }
    } catch (error, stackTrace) {
      logger.error('周期账单编辑', '加载分类失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  Future<void> _saveRecurringTransaction() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);

    // 保存期间阻止重复提交。
    setState(() {
      _saving = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (!_isFormValid()) {
        return;
      }

      // 最终兜底:结束日期不能早于开始日期(选择器已尽量防,这里拦截
      // 任何绕过路径,避免生成 start > end 的非法周期)。
      if (_endDate != null && _endDate!.isBefore(_startDate)) {
        showToast(context, l10n.recurringTransactionEndBeforeStart);
        return;
      }

      // 金额为规范化 decimal 字符串：空/非法即拒绝。
      final amountText = normalizeRecurringAmount(_amountController.text);
      if (amountText == null) {
        showToast(context, l10n.recurringTransactionAmountPrecision);
        return;
      }

      if (_isDraft) {
        // 未落库账本：返回草稿（ledgerId 留空）交由账本统一提交，不写数据库。
        Navigator.of(context).pop(
          buildRecurringDraft(
            id: widget.recurring?.id ?? '',
            amount: amountText,
            currencyCode: _currencyCode!,
            categoryId: _selectedCategory!.id,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            frequency: _frequency.value,
            interval: _interval,
            dayOfMonth: _dayOfMonth,
            dayOfWeek: _dayOfWeek,
            monthOfYear: _monthOfYear,
            timeZone: _timeZone,
            startDate: _startDate,
            endDate: _endDate,
            enabled: _enabled,
          ),
        );
        return;
      }
      final actions = ref.read(transactionActionsProvider);
      if (_isEditing) {
        // 跨端生成进度不允许因编辑开始日期而回退。
        await actions.updateRecurring(
          id: widget.recurring!.id,
          ledgerId: _selectedLedgerId!,
          type: 'expense',
          amount: amountText,
          currencyCode: _currencyCode,
          categoryId: _selectedCategory!.id,

          note: _noteController.text.isEmpty ? null : _noteController.text,
          frequency: _frequency.value,
          interval: _interval,
          dayOfMonth: _dayOfMonth,
          dayOfWeek: _dayOfWeek,
          monthOfYear: _monthOfYear,
          timeZone: _timeZone,
          startDate: _startDate,
          endDate: _endDate,
          enabled: _enabled,
          clearLastGeneratedDate: false,
        );
      } else {
        // 新建模式
        await actions.addRecurring(
          ledgerId: _selectedLedgerId!,
          type: 'expense',
          amount: amountText,
          currencyCode: _currencyCode,
          categoryId: _selectedCategory!.id,

          note: _noteController.text.isEmpty ? null : _noteController.text,
          frequency: _frequency.value,
          interval: _interval,
          dayOfMonth: _dayOfMonth,
          dayOfWeek: _dayOfWeek,
          monthOfYear: _monthOfYear,
          timeZone: _timeZone,
          startDate: _startDate,
          endDate: _endDate,
          enabled: _enabled,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true); // 返回 true 表示数据已更改
      }
    } catch (e, stackTrace) {
      // 使用 logger 记录详细错误信息
      logger.error('周期账单保存', '保存失败', e, stackTrace);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _deleteRecurringTransaction() async {
    if (_deleting) return;
    _deleting = true;
    final l10n = AppLocalizations.of(context);
    try {
      final confirmed = await AppDialog.confirmAsync(
        context,
        title: l10n.commonDelete,
        message: l10n.recurringTransactionDeleteConfirm,
        confirmLabel: l10n.commonDelete,
        onConfirm: () async {
          if (!_isDraft) {
            await ref
                .read(transactionActionsProvider)
                .deleteRecurring(widget.recurring!.id);
          }
        },
        errorMessage: (_) => l10n.commonOperationFailed,
      );
      if (confirmed && mounted) Navigator.of(context).pop(true);
    } finally {
      _deleting = false;
    }
  }
}
