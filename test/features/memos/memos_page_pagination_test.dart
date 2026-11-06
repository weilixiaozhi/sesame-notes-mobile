import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/memos_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';

import '../../helpers/test_isolation.dart';

/// 验证按需创建行仍保留月份分组、加载更多和完整记录访问。
void main() {
  setUp(resetGlobalTestState);

  testWidgets('备忘按月分组，加载更多后能滚动到新增行', (tester) async {
    try {
      final now = DateTime(2026, 11, 6);
      final book = MemoBook(
        id: 'memo-book',
        name: '测试备忘',
        type: memoBookTypeNormal,
        createdAt: now,
        updatedAt: now,
      );
      final entries = [
        for (var index = 0; index < 105; index++)
          MemoEntry(
            id: 'entry-$index',
            memoBookId: book.id,
            bookType: memoBookTypeNormal,
            title: '备忘 $index',
            isSummary: true,
            createdAt: now,
            updatedAt: index < 50 ? now : DateTime(2026, 10, 15),
          ),
      ];
      final limits = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentMemoBookProvider.overrideWithValue(AsyncData(book)),
            currentMemoBookIdProvider.overrideWithBuild(
              (ref, notifier) async => book.id,
            ),
            memoEntriesProvider.overrideWith((ref, query) {
              limits.add(query.limit);
              return Stream.value(entries.take(query.limit).toList());
            }),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            theme: AppTheme.lightTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MemosPage(kind: MemoPageKind.home),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(MemosPage)));
      expect(find.text('2026-11'), findsOneWidget);
      expect(find.text('备忘 0'), findsOneWidget);
      expect(limits, [100]);
      await tester.scrollUntilVisible(
        find.text('2026-10'),
        500,
        maxScrolls: 100,
      );
      expect(find.text('2026-10'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(l.memoMore),
        500,
        maxScrolls: 100,
      );
      await tester.tap(find.text(l.memoMore));
      await tester.pumpAndSettle();
      expect(limits, [100, 200]);
      await tester.scrollUntilVisible(
        find.text('备忘 104'),
        500,
        maxScrolls: 100,
      );
      expect(find.text('备忘 104'), findsOneWidget);
      expect(find.text(l.memoMore), findsNothing);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('备忘列表分页回归失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
