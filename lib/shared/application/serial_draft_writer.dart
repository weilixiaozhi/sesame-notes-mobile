import 'package:sesame_notes/core/logging/logger_service.dart';

/// 串行保存完整草稿，执行当前写入并合并待写快照；离开前可重试最新失败草稿。
class SerialDraftWriter<T extends Object> {
  /// 保存函数绑定原始业务目标，回调只通知当前展示者。
  factory SerialDraftWriter({
    required Future<T> Function(T draft) save,
    required void Function(T saved) onSaved,
    required void Function() onChanged,
  }) => SerialDraftWriter._(save, onSaved, onChanged);

  /// 回调仅由保存队列持有，调用方不能直接绕过队列执行保存。
  SerialDraftWriter._(this._save, this._onSaved, this._onChanged);

  final Future<T> Function(T draft) _save;
  final void Function(T saved) _onSaved;
  final void Function() _onChanged;
  Future<void> _tail = Future.value();
  Future<bool>? _flushing;
  T? _latest;
  ({T draft, int revision})? _queued;
  int _revision = 0;
  int _pending = 0;
  bool _failed = false;
  bool _disposed = false;

  /// 尚未完成的保存数量，用于保留正在输入的草稿。
  int get pending => _pending;

  /// 最近一次保存是否失败，成功重试后自动清除。
  bool get failed => _failed;

  /// 接收覆盖式完整快照；已开始的写入继续完成，尚未开始的输入只保留最新版本。
  void submit(T draft) {
    if (_disposed) throw StateError('草稿保存器已释放');
    _latest = draft;
    final revision = ++_revision;
    if (_pending == 0) {
      _pending = 1;
      _tail = Future<void>.microtask(
        () => _drain((draft: draft, revision: revision)),
      );
    } else {
      _queued = (draft: draft, revision: revision);
      _pending = 2;
    }
    _notify();
  }

  /// 当前写入结束后接管最新待写快照，失败不会丢弃随后到达的有效输入。
  Future<void> _drain(({T draft, int revision}) current) async {
    while (true) {
      try {
        final saved = await _save(current.draft);
        _failed = false;
        // 较早请求的回执不能覆盖用户已经输入的新内容。
        if (!_disposed && current.revision == _revision) _onSaved(saved);
        if (current.revision == _revision) _latest = null;
      } catch (error, stackTrace) {
        _failed = true;
        logger.error(
          'DraftWriter',
          '草稿保存失败，保留输入等待重试',
          safeErrorSummary(error),
          stackTrace,
        );
      }
      final next = _queued;
      _queued = null;
      _pending = next == null ? 0 : 1;
      _notify();
      if (next == null) return;
      current = next;
    }
  }

  /// 同时离开或执行业务动作的调用者共用结果，等待期间接收的新草稿也必须落盘。
  Future<bool> flush() =>
      _flushing ??= _flushPending().whenComplete(() => _flushing = null);

  /// 排空当前及随后接收的草稿，失败时只重试最后一份完整内容一次。
  Future<bool> _flushPending() async {
    var retried = false;
    while (true) {
      await _tail;
      // 保存完成回调也能提交新输入，等待结果不能提前确认这部分内容已经落盘。
      if (_pending > 0) continue;
      if (_failed && _latest != null && !_disposed && !retried) {
        retried = true;
        submit(_latest!);
        continue;
      }
      return !_failed;
    }
  }

  /// 已离开的展示者不再接收通知，已提交的保存仍完成原目标写入。
  void dispose() => _disposed = true;

  /// 展示生命周期只影响回调，不改变持久化队列的执行顺序。
  void _notify() {
    if (_disposed) return;
    try {
      _onChanged();
    } catch (error, stackTrace) {
      logger.error(
        'DraftWriter',
        '草稿状态通知失败，继续完成已提交保存',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }
}
