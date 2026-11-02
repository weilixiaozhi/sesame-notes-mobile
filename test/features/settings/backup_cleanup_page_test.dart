import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/application/backup_cleanup_controller.dart';
import 'package:sesame_notes/features/settings/domain/backup_cleanup.dart';
import 'package:sesame_notes/features/settings/presentation/backup_cleanup_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

import '../../helpers/test_isolation.dart';

const _local = BackupCleanupSource(id: 'local', displayName: 'Local');
const _cloud = BackupCleanupSource(id: 'webdav', displayName: 'WebDAV');

/// 文件状态来自服务替身，页面不得靠名称判断恢复能力或删除资格。
BackupCleanupEntry _entry(
  String key,
  BackupCleanupStatus status, {
  bool protected = false,
}) => BackupCleanupEntry(
  key: key,
  fileName: '$key.snbak',
  sizeBytes: 2048,
  modifiedAt: DateTime.utc(2026, 11, 2),
  createdAt: DateTime.utc(2026, 11, 2),
  status: status,
  sha256:
      const {
        BackupCleanupStatus.current,
        BackupCleanupStatus.unsupported,
        BackupCleanupStatus.auxiliary,
      }.contains(status)
      ? 'checked-$key'
      : null,
  isProtected: protected,
);

/// 只记录页面提交的来源、检查和明确删除，完全不访问本机或云端文件。
class _Manager extends Fake implements BackupCleanupManager {
  /// 页面关闭立即撤销后续操作，替身不持有真实文件任务。
  @override
  void cancelPending() {}
  final previews = <String, BackupCleanupPreview>{};
  final previewCalls = <String>[];
  final inspected = <String>[];
  final deleted = <Set<String>>[];
  final allowWithoutCurrent = <bool>[];
  Object? deleteError;
  BackupCleanupResult? deleteResult;
  Future<BackupCleanupPreview> Function(BackupCleanupPreview, String)?
  inspectHandler;

  /// 来源预览只返回既定元数据，检查调用保持独立可观察。
  @override
  Future<BackupCleanupPreview> preview(String sourceId) async {
    previewCalls.add(sourceId);
    return previews[sourceId]!;
  }

  /// 检查结果可以延迟，用于验证关闭页面后不会继续操作。
  @override
  Future<BackupCleanupPreview> inspect(
    BackupCleanupPreview preview,
    String key,
  ) async {
    inspected.add(key);
    if (inspectHandler != null) return inspectHandler!(preview, key);
    final next = BackupCleanupPreview(
      source: preview.source,
      token: '${preview.token}-checked',
      entries: [
        for (final entry in preview.entries)
          entry.key == key
              ? _entry(key, BackupCleanupStatus.unsupported)
              : entry,
      ],
    );
    previews[preview.source.id] = next;
    return next;
  }

  /// 删除记录完整确认参数，成功后仅从替身清单移除所选项目。
  @override
  Future<BackupCleanupResult> delete(
    BackupCleanupPreview preview,
    Set<String> keys, {
    bool allowNoCurrentBackup = false,
  }) async {
    if (deleteError != null) throw deleteError!;
    deleted.add(Set.of(keys));
    allowWithoutCurrent.add(allowNoCurrentBackup);
    final result =
        deleteResult ??
        BackupCleanupResult(deletedCount: keys.length, failedCount: 0);
    final removed = keys.take(result.deletedCount).toSet();
    previews[preview.source.id] = BackupCleanupPreview(
      source: preview.source,
      token: '${preview.token}-deleted',
      entries: preview.entries
          .where((entry) => !removed.contains(entry.key))
          .toList(),
    );
    return result;
  }
}

/// 使用实际页面、项目组件与英文文案，替换服务以避免任何真实删除。
Future<void> _pump(
  WidgetTester tester,
  _Manager manager, {
  String? initialSourceId,
}) async {
  try {
    tester.view.physicalSize = const Size(430, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupCleanupSourcesProvider.overrideWith(
            (_) async => [_local, _cloud],
          ),
          backupCleanupManagerProvider.overrideWithValue(manager),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BackupCleanupPage(initialSourceId: initialSourceId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } catch (error, stack) {
    debugPrint('备份管理页面装配失败：$error\n$stack');
    rethrow;
  }
}

/// 收尾提示计时器及页面持有者，不把迟到异步留给后续用例。
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 4));
}

/// 清单初始全不选，检查下载和删除确认分别验证。
void main() {
  setUp(resetGlobalTestState);

  testWidgets('默认不勾选，最新有效与未知文件没有删除选择框', (tester) async {
    final manager = _Manager();
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'local',
      entries: [
        _entry('current', BackupCleanupStatus.current, protected: true),
        _entry('historical', BackupCleanupStatus.unsupported),
        _entry('unchecked', BackupCleanupStatus.unverified),
        _entry('unknown', BackupCleanupStatus.unknown),
      ],
    );
    try {
      await _pump(tester, manager);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(
        find.byKey(const ValueKey('backup-cleanup-select:current')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('backup-cleanup-select:unknown')),
        findsNothing,
      );
      expect(
        find.textContaining('Newest verified current backup · kept'),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(manager.inspected, isEmpty);
      expect(manager.deleted, isEmpty);
    } finally {
      await _close(tester);
    }
  });

  testWidgets('云端列表不下载，单文件检查先说明大小且取消不检查', (tester) async {
    final manager = _Manager();
    manager.previews['webdav'] = BackupCleanupPreview(
      source: _cloud,
      token: 'cloud',
      entries: [_entry('cloud-file', BackupCleanupStatus.unverified)],
    );
    try {
      await _pump(tester, manager, initialSourceId: 'webdav');
      expect(manager.inspected, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-inspect:cloud-file')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Check this cloud file?'), findsOneWidget);
      expect(find.textContaining('cloud-file.snbak (2.0 KB)'), findsOneWidget);
      expect(manager.inspected, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(manager.inspected, isEmpty);
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-inspect:cloud-file')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check file').last);
      await tester.pumpAndSettle();
      expect(manager.inspected, ['cloud-file']);
      expect(
        find.byKey(const ValueKey('backup-cleanup-select:cloud-file')),
        findsOneWidget,
      );
    } finally {
      await _close(tester);
    }
  });

  testWidgets('没有已核验当前备份时，第二次确认前不得删除', (tester) async {
    final manager = _Manager();
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'historical',
      entries: [_entry('historical', BackupCleanupStatus.unsupported)],
    );
    try {
      await _pump(tester, manager);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete selected (1)'));
      await tester.pumpAndSettle();
      expect(manager.deleted, isEmpty);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No verified current backup'), findsOneWidget);
      expect(manager.deleted, isEmpty);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(manager.deleted, isEmpty);
      await tester.tap(find.text('Delete selected (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete historical files'));
      await tester.pumpAndSettle();
      expect(manager.deleted, [
        {'historical'},
      ]);
      expect(manager.allowWithoutCurrent, [true]);
    } finally {
      await _close(tester);
    }
  });

  testWidgets('当前快照保留时只提交明确勾选的历史文件', (tester) async {
    final manager = _Manager();
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'with-current',
      entries: [
        _entry('current', BackupCleanupStatus.current, protected: true),
        _entry('historical', BackupCleanupStatus.unsupported),
      ],
    );
    try {
      await _pump(tester, manager);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete selected (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(manager.deleted, [
        {'historical'},
      ]);
      expect(manager.allowWithoutCurrent, [false]);
      expect(
        find.textContaining('Newest verified current backup · kept'),
        findsOneWidget,
      );
    } finally {
      await _close(tester);
    }
  });

  testWidgets('清单身份失效后清空勾选并重新读取来源', (tester) async {
    final manager = _Manager()
      ..deleteError = const BackupCleanupException(
        BackupCleanupFailure.stalePreview,
      );
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'stale',
      entries: [
        _entry('current', BackupCleanupStatus.current, protected: true),
        _entry('historical', BackupCleanupStatus.unsupported),
      ],
    );
    try {
      await _pump(tester, manager);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete selected (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(manager.deleted, isEmpty);
      expect(manager.previewCalls, ['local', 'local']);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(find.text('Delete selected (0)'), findsOneWidget);
    } finally {
      await _close(tester);
    }
  });

  testWidgets('页面关闭后迟到检查不会更新界面或触发删除', (tester) async {
    final manager = _Manager();
    final completion = Completer<BackupCleanupPreview>();
    final preview = BackupCleanupPreview(
      source: _local,
      token: 'late',
      entries: [_entry('unchecked', BackupCleanupStatus.unverified)],
    );
    manager.previews['local'] = preview;
    manager.inspectHandler = (_, _) => completion.future;
    try {
      await _pump(tester, manager);
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-inspect:unchecked')),
      );
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      completion.complete(preview);
      await tester.pumpAndSettle();
      expect(manager.deleted, isEmpty);
      expect(tester.takeException(), isNull);
    } finally {
      await _close(tester);
    }
  });

  testWidgets('切换来源清空选择，云端新清单不会沿用本机删除名单', (tester) async {
    final manager = _Manager();
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'local-source',
      entries: [_entry('local-history', BackupCleanupStatus.unsupported)],
    );
    manager.previews['webdav'] = BackupCleanupPreview(
      source: _cloud,
      token: 'cloud-source',
      entries: [_entry('cloud-unchecked', BackupCleanupStatus.unverified)],
    );
    try {
      await _pump(tester, manager);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(find.text('Delete selected (1)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('backup-cleanup-source')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WebDAV').last);
      await tester.pumpAndSettle();
      expect(manager.previewCalls, ['local', 'webdav']);
      expect(find.text('Delete selected (0)'), findsOneWidget);
      expect(manager.inspected, isEmpty);
      expect(manager.deleted, isEmpty);
    } finally {
      await _close(tester);
    }
  });

  testWidgets('部分失败明确显示删除与保留数量，并重新加载剩余文件', (tester) async {
    final manager = _Manager()
      ..deleteResult = const BackupCleanupResult(
        deletedCount: 2,
        failedCount: 1,
      );
    manager.previews['local'] = BackupCleanupPreview(
      source: _local,
      token: 'partial',
      entries: [
        _entry('current', BackupCleanupStatus.current, protected: true),
        _entry('history-a', BackupCleanupStatus.unsupported),
        _entry('history-b', BackupCleanupStatus.unsupported),
        _entry('history-c', BackupCleanupStatus.unsupported),
      ],
    );
    try {
      await _pump(tester, manager);
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-select:history-a')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-select:history-b')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('backup-cleanup-select:history-c')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete selected (3)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Confirmed deleted: 2; incomplete or awaiting confirmation: 1. Refresh to check.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('backup-cleanup-select:history-c')),
        findsOneWidget,
      );
      expect(find.text('Delete selected (0)'), findsOneWidget);
    } finally {
      await _close(tester);
    }
  });
}
