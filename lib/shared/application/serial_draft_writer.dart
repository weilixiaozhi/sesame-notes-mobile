import 'package:sesame_notes/core/logging/logger_service.dart';

/// 串行保存编辑意图，只发布最新回执；离开前可重试最后一个失败草稿。
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
  T? _latest;
  int _revision = 0;
  int _pending = 0;
  bool _failed = false;
  bool _disposed = false;

  /// 尚未完成的保存数量，用于保留正在输入的草稿。
  int get pending => _pending;

  /// 最近一次保存是否失败，成功重试后自动清除。
  bool get failed => _failed;

  /// 追加一个保存意图，前序错误不会阻断后续有效输入。
  void submit(T draft) {
    if (_disposed) throw StateError('草稿保存器已释放');
    _latest = draft;
    final revision = ++_revision;
    _pending++;
    _notify();
    _tail = _tail.then((_) async {
      try {
        final saved = await _save(draft);
        _failed = false;
        // 较早请求的回执不能覆盖用户已经输入的新内容。
        if (!_disposed && revision == _revision) _onSaved(saved);
      } catch (error, stackTrace) {
        _failed = true;
        logger.error(
          'DraftWriter',
          '草稿保存失败，保留输入等待重试',
          safeErrorSummary(error),
          stackTrace,
        );
      } finally {
        _pending--;
        _notify();
      }
    });
  }

  /// 等待全部输入落盘，失败时只重试最新草稿一次。
  Future<bool> flush() async {
    await _tail;
    if (_failed && _latest != null && !_disposed) {
      submit(_latest!);
      await _tail;
    }
    return !_failed;
  }

  /// 已离开的展示者不再接收通知，已提交的保存仍完成原目标写入。
  void dispose() => _disposed = true;

  /// 展示生命周期只影响回调，不改变持久化队列的执行顺序。
  void _notify() {
    if (!_disposed) _onChanged();
  }
}
