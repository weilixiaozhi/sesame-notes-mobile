import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/features/categories/presentation/category_template_submission.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 记录真实确认流程的返回值和异常，避免测试异步回调遗留未处理错误。
class _SubmissionProbe {
  TemplateSubmissionSummary? result;
  Object? error;
  StackTrace? stackTrace;
  final writing = <bool>[];

  /// 外层页面承担异常处理，提交函数只负责保留各轮结果。
  Future<void> start(
    BuildContext context,
    Future<TemplateInsertResult> Function(Set<String>) execute,
  ) async {
    try {
      result = await submitCategoryTemplatePlan(
        context,
        count: 4,
        execute: execute,
        onWriting: writing.add,
      );
    } catch (failure, stack) {
      error = failure;
      stackTrace = stack;
    }
  }
}

/// 构造只用于分轮协议的模板身份，测试始终使用真实确认弹窗。
CategoryTemplateItem _item(String id) => CategoryTemplateItem(
  key: id,
  name: id,
  iconName: 'restaurant',
  syncId: id,
  level: 1,
  alreadyAdded: false,
);

/// 只返回已经完成的数量和需要下一次明确确认的身份。
TemplateInsertResult _result({
  int created = 0,
  int restored = 0,
  List<CategoryTemplateItem> pending = const [],
  List<CategoryTemplateItem> restore = const [],
}) => TemplateInsertResult(
  created: created,
  restored: restored,
  skipped: 0,
  pending: pending,
  localRestoreRequired: restore,
);

/// 安装最小页面并打开正式提交确认框。
Future<_SubmissionProbe> _begin(
  WidgetTester tester,
  Future<TemplateInsertResult> Function(Set<String>) execute,
) async {
  try {
    final probe = _SubmissionProbe();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => probe.start(context, execute),
              child: const Text('开始'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('开始'));
    await tester.pumpAndSettle();
    return probe;
  } catch (error, stack) {
    debugPrint('安装模板分轮测试页面失败：$error\n$stack');
    rethrow;
  }
}

/// 点击明确确认按钮，等待该轮写入及后续确认界面稳定。
Future<void> _confirm(WidgetTester tester, String label) async {
  try {
    await tester.tap(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  } catch (error, stack) {
    debugPrint('模板分轮确认失败：$label，$error\n$stack');
    rethrow;
  }
}

/// 验证部分提交、普通失败和主动取消各自保持准确语义。
void main() {
  final l10n = lookupAppLocalizations(const Locale('zh'));

  testWidgets('第三轮失败保留前两轮新增恢复与去重待确认数量及原始错误堆栈', (tester) async {
    try {
      final approvals = <Set<String>>[];
      final cause = StateError('第三轮存储失败');
      final originalStack = StackTrace.fromString(
        'original-restore-write-stack',
      );
      final probe = await _begin(tester, (ids) async {
        approvals.add(ids);
        return switch (approvals.length) {
          1 => _result(
            created: 1,
            pending: [_item('pending-a')],
            restore: [_item('parent')],
          ),
          2 => _result(
            restored: 1,
            pending: [_item('pending-a'), _item('pending-b')],
            restore: [_item('child')],
          ),
          _ => Error.throwWithStackTrace(cause, originalStack),
        };
      });
      await _confirm(tester, l10n.commonConfirm);
      expect(probe.writing, [true, false], reason: '等待用户确认时写入状态必须释放');
      await _confirm(tester, l10n.categoryTemplateRestoreConfirm);
      await _confirm(tester, l10n.categoryTemplateRestoreConfirm);
      final failure = probe.error! as TemplateSubmissionFailure;
      expect(failure.completed.created, 1);
      expect(failure.completed.restored, 1);
      expect(failure.completed.pendingCount, 2);
      expect(failure.cause, same(cause));
      expect(failure.stackTrace, same(originalStack));
      expect(probe.stackTrace.toString(), originalStack.toString());
      expect(probe.result, isNull);
      expect(probe.writing, [true, false, true, false, true, false]);
      expect(approvals, [
        <String>{},
        {'parent'},
        {'parent', 'child'},
      ]);
      for (final locale in [
        const Locale('en'),
        const Locale('zh'),
        const Locale('zh', 'TW'),
      ]) {
        final translated = lookupAppLocalizations(locale);
        expect(
          failure.describe(translated),
          translated.categoryTemplatePartiallyCompleted(
            '${translated.categoryTemplateAddSuccess(1)}\n'
            '${translated.categoryTemplateRestored(1)}\n'
            '${translated.categoryTemplatePending(2)}',
          ),
        );
      }
    } catch (error, stack) {
      debugPrint('分轮累计结果验证失败：$error\n$stack');
      rethrow;
    }
  });

  testWidgets('初次写入失败仍原样抛出且释放写入状态', (tester) async {
    try {
      final cause = StateError('首轮失败');
      final probe = await _begin(tester, (_) async => throw cause);
      await _confirm(tester, l10n.commonConfirm);
      expect(probe.error, same(cause));
      expect(probe.error, isNot(isA<TemplateSubmissionFailure>()));
      expect(probe.result, isNull);
      expect(probe.writing, [true, false]);
    } catch (error, stack) {
      debugPrint('首次写入失败语义验证失败：$error\n$stack');
      rethrow;
    }
  });

  testWidgets('初次取消不写入，恢复取消保留首轮已提交摘要', (tester) async {
    try {
      var writes = 0;
      final cancelled = await _begin(tester, (_) async {
        writes++;
        return _result();
      });
      await _confirm(tester, l10n.commonCancel);
      expect(writes, 0);
      expect(cancelled.result, isNull);
      expect(cancelled.error, isNull);
      expect(cancelled.writing, isEmpty);

      final partial = await _begin(tester, (_) async {
        writes++;
        return _result(created: 1, restore: [_item('deleted')]);
      });
      await _confirm(tester, l10n.commonConfirm);
      await _confirm(tester, l10n.commonCancel);
      expect(writes, 1);
      expect(partial.result!.created, 1);
      expect(partial.error, isNull);
      expect(partial.writing, [true, false]);
    } catch (error, stack) {
      debugPrint('模板取消语义验证失败：$error\n$stack');
      rethrow;
    }
  });

  testWidgets('前轮没有提交变化时后轮失败保持普通失败提示', (tester) async {
    try {
      var writes = 0;
      final probe = await _begin(tester, (_) async {
        if (writes++ == 0) return _result(restore: [_item('deleted')]);
        throw StateError('恢复失败');
      });
      await _confirm(tester, l10n.commonConfirm);
      await _confirm(tester, l10n.categoryTemplateRestoreConfirm);
      final failure = probe.error! as TemplateSubmissionFailure;
      expect(failure.completed.hasChanges, isFalse);
      expect(
        failure.describe(l10n),
        l10n.categoryTemplateAddFailed(l10n.commonOperationFailed),
      );
    } catch (error, stack) {
      debugPrint('空提交失败提示验证失败：$error\n$stack');
      rethrow;
    }
  });
}
