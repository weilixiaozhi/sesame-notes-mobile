import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_order.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/memo_credentials_page.dart';
import 'package:sesame_notes/features/memos/presentation/widgets/memo_entry_tile.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 保留真实列表交互，用例替身只记录最终持久化请求。
class _Actions extends Mock implements MemoActions {}

/// 在手机窄屏验证排序入口和手势保存，不依赖设备原生排序通道。
void main() {
  final time = DateTime.utc(2026);
  final book = MemoBook(
    id: 'book',
    name: '账号密码',
    type: memoBookTypeCredentials,
    createdAt: time,
    updatedAt: time,
  );
  final entries = [
    for (var index = 0; index < 3; index++)
      MemoEntry(
        id: 'entry$index',
        memoBookId: book.id,
        bookType: memoBookTypeCredentials,
        title: ['账号10', '账号2', '微信'][index],
        createdAt: time,
        updatedAt: time,
        orderKey: index,
        isSummary: true,
      ),
  ];
  const target = (bookId: 'book', accountId: null, generation: 0, syncId: null);
  setUpAll(() => registerFallbackValue(target));

  testWidgets('名称排序后拖动卡片保存可见顺序并回到手动模式', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final actions = _Actions();
    final requests = <CredentialSort>[];
    final saved = <List<String>>[];
    when(() => actions.target(book.id)).thenAnswer((_) async => target);
    when(() => actions.reorderCredentials(target, any(), any())).thenAnswer((
      invocation,
    ) async {
      saved.add(
        List<String>.of(invocation.positionalArguments[2] as List<String>),
      );
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentCredentialBookProvider.overrideWith((ref) => AsyncData(book)),
          credentialOrderTargetProvider.overrideWith((ref) => target),
          memoActionsProvider.overrideWithValue(actions),
          memoCredentialEntriesProvider.overrideWith((ref, query) {
            requests.add(query.sort);
            final visible = query.sort == CredentialSort.title
                ? [entries[2], entries[1], entries[0]]
                : entries;
            return Stream.value(visible);
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MemoCredentialsPage(embedded: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(requests.last, CredentialSort.manual);
    await tester.tap(find.byType(PopupMenuButton<CredentialSort>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('名称').last);
    await tester.pumpAndSettle();
    expect(requests.last, CredentialSort.title);
    expect(
      tester
          .widgetList<MemoEntryTile>(find.byType(MemoEntryTile))
          .map((tile) => tile.entry.id),
      ['entry2', 'entry1', 'entry0'],
    );

    final handles = find.byType(ReorderableDragStartListener);
    final start = tester.getCenter(handles.first);
    final end = tester.getCenter(handles.at(2));
    final gesture = await tester.startGesture(start);
    await tester.pump();
    await gesture.moveBy(const Offset(0, 12));
    await tester.pump();
    // 将拖动卡片完整越过末行的中线，确保目标为最后一项。
    await gesture.moveTo(end + const Offset(0, 100));
    await tester.pump(const Duration(milliseconds: 350));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(saved, [
      ['entry1', 'entry0', 'entry2'],
    ]);
    expect(requests.last, CredentialSort.manual);
    expect(tester.takeException(), isNull);
  });

  for (final changedTarget in <PrivateBookTarget>[
    (bookId: 'book', accountId: 'another', generation: 0, syncId: null),
    (bookId: 'book', accountId: null, generation: 1, syncId: null),
    (bookId: 'book', accountId: null, generation: 0, syncId: 'new-binding'),
  ]) {
    testWidgets('手势期间身份变为 $changedTarget 时取消旧顺序提交', (tester) async {
      final actions = _Actions();
      PrivateBookTarget currentTarget = target;
      final container = ProviderContainer(
        overrides: [
          currentCredentialBookProvider.overrideWith((ref) => AsyncData(book)),
          credentialOrderTargetProvider.overrideWith((ref) => currentTarget),
          memoActionsProvider.overrideWithValue(actions),
          memoCredentialEntriesProvider.overrideWith(
            (ref, query) => Stream.value(entries),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const MemoCredentialsPage(embedded: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final handles = find.byType(ReorderableDragStartListener);
      final end = tester.getCenter(handles.at(2));
      final gesture = await tester.startGesture(
        tester.getCenter(handles.first),
      );
      await gesture.moveBy(const Offset(0, 40));
      await tester.pump(const Duration(milliseconds: 350));
      currentTarget = changedTarget;
      container.invalidate(credentialOrderTargetProvider);
      await tester.pump();
      await gesture.moveTo(end + const Offset(0, 100));
      await tester.pump(const Duration(milliseconds: 350));
      await gesture.up();
      await tester.pumpAndSettle();
      verifyNever(() => actions.reorderCredentials(any(), any(), any()));
      expect(tester.takeException(), isNull);
    });
  }
}
