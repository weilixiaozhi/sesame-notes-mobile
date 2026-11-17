import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_history_section.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

const _recordId = 'history-record';

/// 详情历史区块只依赖本机读取结果，测试用可控 Stream 替代数据库订阅。
Widget _historyApp(
  Stream<List<RecordEditHistoryDisplay>> stream, {
  String? fallbackCategoryName,
  String? fallbackAmount,
  DateTime? fallbackHappenedAt,
}) => ProviderScope(
  overrides: [
    recordEditHistoryProvider(_recordId).overrideWith((ref) => stream),
  ],
  child: MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: TransactionHistorySection(
        recordId: _recordId,
        // 本机成员目录能解析本机历史；云端条目使用缓存的服务端名称兜底。
        displayNameOf: (id) => id == null ? '本机成员' : '',
        fallbackCategoryName: fallbackCategoryName,
        fallbackAmount: fallbackAmount,
        fallbackHappenedAt: fallbackHappenedAt,
      ),
    ),
  ),
);

void main() {
  testWidgets('读取中不显示转圈和重试', (tester) async {
    final controller = StreamController<List<RecordEditHistoryDisplay>>();
    addTearDown(controller.close);
    await tester.pumpWidget(_historyApp(controller.stream));
    await tester.pump();

    // 首次读取不占位、不转圈，也不出现重试入口。
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('重试'), findsNothing);
    expect(find.text('暂无编辑历史'), findsNothing);
  });

  testWidgets('读取失败按暂无历史展示，不出现错误或重试', (tester) async {
    await tester.pumpWidget(
      _historyApp(Stream.error(StateError('network down'))),
    );
    await tester.pump();

    expect(find.text('暂无编辑历史'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('重试'), findsNothing);
  });

  testWidgets('本机与云端缓存历史一起展示，云端使用旧格式摘要且不显示版本号', (tester) async {
    await tester.pumpWidget(
      _historyApp(
        Stream.value([
          RecordEditHistoryDisplay(
            version: 2,
            summary: '本地摘要',
            isCloud: false,
            createdAt: DateTime.utc(2026, 11, 3, 10, 2),
          ),
          RecordEditHistoryDisplay(
            version: 3,
            operatorMemberId: 'cloud-member',
            operatorDisplayName: '远端成员',
            changes: const {
              'display': {
                'action': 'edit',
                'category_name': '餐饮',
                'amount': '12.34',
                'happened_at': '2026-11-03T10:03:00.000Z',
                'note_changed': true,
                'sharing_changed': true,
              },
            },
            isCloud: true,
            createdAt: DateTime.utc(2026, 11, 3, 10, 3),
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地摘要'), findsOneWidget);
    expect(find.textContaining('餐饮'), findsOneWidget);
    expect(find.textContaining('12.34'), findsOneWidget);
    expect(find.textContaining('备注已更新'), findsOneWidget);
    expect(find.textContaining('分摊已调整'), findsOneWidget);
    expect(find.textContaining('远端成员'), findsOneWidget);
    expect(find.text('v2'), findsNothing);
    expect(find.text('v3'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('重试'), findsNothing);
  });

  testWidgets('老云端历史缺少展示快照时用当前交易回退旧格式', (tester) async {
    await tester.pumpWidget(
      _historyApp(
        Stream.value([
          RecordEditHistoryDisplay(
            version: 2,
            operatorMemberId: 'cloud-member',
            changes: const {
              'amount': '9.5',
              'happened_at': '2026-11-03T10:00:00.000Z',
            },
            isCloud: true,
            createdAt: DateTime.utc(2026, 11, 3, 10, 0),
          ),
        ]),
        fallbackCategoryName: '交通',
        fallbackAmount: '9.5',
        fallbackHappenedAt: DateTime.utc(2026, 11, 3, 10),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('交通'), findsOneWidget);
    expect(find.textContaining('9.50'), findsOneWidget);
    expect(find.textContaining('备注已更新'), findsNothing);
    expect(find.textContaining('分摊已调整'), findsNothing);
  });
}
