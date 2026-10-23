import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 多个业务入口共用纯模型的分类文案，不依赖其他功能的页面组件。
String dayCategoryLabel(AppLocalizations l10n, String category) =>
    switch (category) {
      DayCategory.birthday => l10n.dayBirthday,
      DayCategory.anniversary => l10n.dayAnniversary,
      DayCategory.countdown => l10n.dayCountdown,
      _ => l10n.dayStage,
    };
