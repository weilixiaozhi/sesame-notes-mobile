import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 按账号和账本持久保存待全量下载事实，独立键避免并发更新覆盖其他账本。
class CloudLedgerDownloadStore {
  static const _initial = 'initial';
  static const _refresh = 'refresh';

  /// 复用应用统一的偏好存储入口，成功写入后通知展示状态重算。
  CloudLedgerDownloadStore(
    this.loadPreferences, {
    this.onChanged,
    this.onPublicationChanged,
  });

  final Future<SharedPreferences> Function() loadPreferences;
  final void Function()? onChanged;
  final void Function()? onPublicationChanged;

  /// 编码账号，确保账号前缀与账本键的边界不受标识符内容影响。
  String _prefix(String accountId) =>
      'cloud_pending_full:${Uri.encodeComponent(accountId)}:';

  /// 读取当前账号需要完整快照的账本集合。
  Future<Set<String>> pending(String accountId) =>
      _readPending(accountId, initialOnly: false);

  /// 首次快照尚未提交的账本不进入展示。
  Future<Set<String>> unpublished(String accountId) =>
      _readPending(accountId, initialOnly: true);

  /// 偏好边界只接受当前任务模式；异常值必须先被明确处理，不能被忽略或覆盖。
  String? _readMode(SharedPreferences prefs, String key) =>
      switch (prefs.get(key)) {
        null => null,
        _initial => _initial,
        _refresh => _refresh,
        _ => throw const FormatException('待下载账本状态格式无效，请检查本机存储'),
      };

  /// 两类任务共用账号隔离键，后台刷新只参与重试，不撤销已发布快照。
  Future<Set<String>> _readPending(
    String accountId, {
    required bool initialOnly,
  }) async {
    try {
      final prefs = await loadPreferences();
      final prefix = _prefix(accountId);
      final ids = <String>{};
      for (final key in prefs.getKeys().where(
        (key) => key.startsWith(prefix),
      )) {
        final mode = _readMode(prefs, key);
        if (mode == _initial || !initialOnly && mode == _refresh) {
          ids.add(Uri.decodeComponent(key.substring(prefix.length)));
        }
      }
      return ids;
    } catch (error, stackTrace) {
      logger.error(
        'CloudLedgerDownload',
        '读取待下载账本失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 在下载前持久登记任务；已有首次任务不能仅因占位行存在而升级为后台刷新。
  Future<void> markPending(
    String accountId,
    String ledgerId, {
    bool hasLocalSnapshot = false,
  }) => _setPending(
    accountId,
    ledgerId,
    true,
    hasLocalSnapshot: hasLocalSnapshot,
  );

  /// 仅完整快照事务成功提交后，才解除账本待下载状态。
  Future<void> markReady(String accountId, String ledgerId) =>
      _setPending(accountId, ledgerId, false);

  /// 账本被删除、退出或明确撤权后清理下载任务，不把网络失败视为撤权。
  Future<void> forget(String accountId, String ledgerId) =>
      _setPending(accountId, ledgerId, false);

  /// 仅改变目标账本的独立键，持久化失败时让调用方停止后续落库。
  Future<void> _setPending(
    String accountId,
    String ledgerId,
    bool value, {
    bool hasLocalSnapshot = false,
  }) async {
    try {
      final prefs = await loadPreferences();
      final key = '${_prefix(accountId)}${Uri.encodeComponent(ledgerId)}';
      final previous = _readMode(prefs, key);
      final wasUnpublished = previous == _initial;
      final mode = !hasLocalSnapshot || previous == _initial
          ? _initial
          : _refresh;
      if (value ? previous == mode : !prefs.containsKey(key)) return;
      final saved = value
          ? await prefs.setString(key, mode)
          : await prefs.remove(key);
      if (!saved) throw StateError('待下载账本状态未能保存');
      onChanged?.call();
      if (wasUnpublished != (value && mode == _initial)) {
        onPublicationChanged?.call();
      }
    } catch (error, stackTrace) {
      logger.error(
        'CloudLedgerDownload',
        '保存待下载账本状态失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 账号数据清理完成后移除其下载任务，其他账号保持原样。
  Future<void> forgetAccount(String accountId) async {
    final ids = await pending(accountId);
    await Future.wait([for (final id in ids) forget(accountId, id)]);
  }

  /// 无有效账号且云端数据清空后，移除孤立的下载标记并保留其他偏好。
  Future<void> forgetAll() async {
    try {
      final prefs = await loadPreferences();
      final keys = prefs
          .getKeys()
          .where((key) => key.startsWith('cloud_pending_full:'))
          .toList();
      if (keys.isEmpty) return;
      // 先校验全部目标再清理，任一标记无效时不能先删除其他有效任务。
      final modes = [for (final key in keys) _readMode(prefs, key)];
      final hadUnpublished = modes.contains(_initial);
      for (final key in keys) {
        if (!await prefs.remove(key)) throw StateError('待下载账本状态未能清除');
      }
      onChanged?.call();
      if (hadUnpublished) onPublicationChanged?.call();
    } catch (error, stackTrace) {
      logger.error(
        'CloudLedgerDownload',
        '清理全部待下载账本失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}
