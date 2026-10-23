import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/contracts/day_repositories.dart';
import 'package:sesame_notes/features/days/application/day_editor_validation.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';

/// 编辑器表单的当前取值快照，定义组装只依赖这些显式输入。
typedef DayEditorDraft = ({
  String category,
  String countdown,
  String repeat,
  String statistic,
  String name,
  String intervalText,
  OriginalDate event,
  OriginalDate start,
  OriginalDate end,
  bool untilPresent,
  DateOnly today,
});

/// 校验记录的原始日期能否静态读取，损坏投影与非法定义都抛出稳定代码。
void requireReadableDayDates(DayEvent event) {
  if (event.hasUnreadableDate) {
    throw const DayDateException('unreadable_projection');
  }
  const DayDateRules().validateAndProject(event.definition);
}

/// 无法读取的记录需要重新确认全部已填写的原始日期端点。
Set<String> unconfirmedDayDateKeys(DayEvent event) => {
  if (event.definition.event != null) 'event',
  if (event.definition.start != null) 'start',
  if (event.definition.end != null) 'end',
};

/// 按当前分类组装业务定义：阶段默认至今，其他分类只保存各自的日期端点。
///
/// 天数输入只接受完整整数，非法文本保留为空由静态校验拒绝，不静默改写。
DayEventDefinition buildDayEditorDefinition(
  DayEditorDraft draft, {
  DayEventDefinition? original,
}) {
  final hasStart =
      draft.category == DayCategory.stage ||
      draft.category == DayCategory.countdown &&
          draft.countdown == DayCountdownMode.intervalDays;
  return validateDayEditorDefinition(
    DayEventDefinition(
      category: draft.category,
      name: draft.name,
      repeatType: draft.repeat,
      statisticType: draft.statistic,
      countdownMode: draft.category == DayCategory.countdown
          ? draft.countdown
          : null,
      intervalDays:
          draft.category == DayCategory.countdown &&
              draft.countdown == DayCountdownMode.intervalDays
          ? int.tryParse(draft.intervalText)
          : null,
      event: hasStart ? null : draft.event,
      start: hasStart ? draft.start : null,
      end: draft.category == DayCategory.stage && !draft.untilPresent
          ? draft.end
          : null,
    ),
    draft.today,
    original: original,
  );
}

/// 编辑器提交：固定目标本、账号与绑定全部有效后，业务定义在仓储事务落库。
///
/// 未重新确认的日期、已失效的目标本都直接失败，不产生任何记录也不新增副本。
Future<DayEventDefinition> saveDayEditorEvent({
  required DayEntryRepository repository,
  required DayEditorArgs args,
  required String? currentAccountId,
  required Set<String> unconfirmedDates,
  required DayEditorDraft draft,
  required String eventId,
  required DateTime createdAt,
}) async {
  // 待修复的原始日期必须先由用户重新选择确认，不能带着坏投影直接落库。
  if (unconfirmedDates.isNotEmpty) {
    throw const DayDateException('date_confirmation_required');
  }
  if (currentAccountId != args.accountId ||
      repository.generationGetter() != args.generation) {
    throw StateError('账号已改变');
  }
  // 重新读取固定目标本：编辑器打开后外部切本、删本或换绑都不能改变写入目标。
  final target = await repository.getBook(
    args.book.id,
    accountId: args.accountId,
  );
  if (target == null ||
      target.pendingLocalDelete ||
      target.isStale ||
      target.storageMode != args.book.storageMode ||
      (args.book.syncId != null && target.syncId != args.book.syncId)) {
    throw StateError('目标日子本已失效');
  }
  final definition = buildDayEditorDefinition(
    draft,
    original: args.event?.definition,
  );
  await repository.saveEventAtTarget(
    DayEvent(
      id: eventId,
      dayBookId: args.book.id,
      definition: definition,
      createdAt: createdAt,
      updatedAt: DateTime.now().toUtc(),
      serverRevision: args.event?.serverRevision,
    ),
    (
      bookId: args.book.id,
      accountId: args.accountId,
      generation: args.generation,
      syncId: args.book.syncId,
    ),
  );
  return definition;
}
