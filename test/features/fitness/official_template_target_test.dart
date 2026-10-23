import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_template_detail_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 只记录正式应用操作边界，测试不写入数据库或外部服务。
class _RecordingActions extends Fake implements FitnessActions {
  /// 每个实例代表不同的已选择空间。
  _RecordingActions(String space)
    : target = (bookId: space, accountId: null, generation: 0, syncId: null);

  @override
  final PrivateBookTarget target;
  int imports = 0;

  /// 实际进入写入边界才计数，用于判断迟到选择有没有写入其他空间。
  @override
  Future<FitnessTemplate> importCatalogTemplate(
    FitnessTemplate official, {
    String? reuseTemplateId,
  }) async {
    imports++;
    return official;
  }
}

/// 等待用户副本查询期间切空间，原添加动作必须取消而不是落到新空间。
void main() {
  testWidgets('官方模板添加固定点击时空间，迟到副本结果不能写入新空间', (tester) async {
    final first = _RecordingActions('first');
    final second = _RecordingActions('second');
    var current = first;
    final templates = StreamController<List<FitnessTemplate>>.broadcast();
    final analytics = ProductAnalyticsController(
      writer: () async => throw StateError('测试不启用上传'),
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity(null, 0),
        enabled: false,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        fitnessActionsProvider.overrideWith((ref) => current),
        fitnessTemplatesProvider.overrideWith((ref) => templates.stream),
        fitnessCatalogProvider.overrideWith((ref) async => []),
        productAnalyticsControllerProvider.overrideWithValue(analytics),
      ],
    );
    const text = FitnessLibraryText(zh: '官方训练', zhHant: '官方訓練', en: 'Official');
    const official = OfficialFitnessTemplate(
      id: 'official',
      revision: 1,
      name: text,
      description: text,
      difficulty: 'beginner',
      goals: {},
      durationMinutes: 10,
      equipment: [],
      exercises: [],
    );
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const FitnessTemplateDetailPage(
              templateId: 'official',
              official: official,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).last);
      await tester.pump();
      current = second;
      container.invalidate(fitnessActionsProvider);
      templates.add([]);
      await tester.pumpAndSettle();
      expect(first.imports, 0);
      expect(second.imports, 0);
      expect(find.byType(FitnessTemplateDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
      // 错误反馈有独立的自动关闭计时器，先推进到关闭后再释放页面。
      await tester.pump(const Duration(seconds: 2));
    } catch (error, stackTrace) {
      debugPrint('官方模板目标隔离回归失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      final closed = templates.close();
      await tester.pump();
      await closed;
      analytics.dispose();
    }
  });
}
