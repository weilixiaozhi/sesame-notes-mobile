import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/models/memo.dart';

enum MemoSaveState { unchanged, editing, saving, saved, failed }

/// 每个编辑会话只写固定目标；后续输入排队，失败保留最新完整快照。
class MemoDraft extends ChangeNotifier {
  final Future<void> Function(MemoEntry) save;
  final bool automatic;
  final void Function(MemoEntry)? onSnapshot;
  MemoEntry Function()? _snapshot;
  MemoDraft({required this.save, this.automatic = true, this.onSnapshot});
  MemoEntry? _pending;
  Timer? _timer;
  Future<void>? _writing;
  var _version = 0;
  var _savedVersion = 0;
  var _disposed = false;
  MemoSaveState state = MemoSaveState.unchanged;
  bool get dirty => _version != _savedVersion;
  MemoEntry? get value {
    if (_snapshot case final capture?) {
      _pending = capture();
      _snapshot = null;
      onSnapshot?.call(_pending!);
    }
    return _pending;
  }

  void _state(MemoSaveState value) {
    state = value;
    if (!_disposed) notifyListeners();
  }

  void edit(MemoEntry value) {
    _pending = value;
    _snapshot = null;
    _changed();
  }

  /// 输入只登记版本，完整正文在防抖到期、离开或后台保存时生成。
  void editLazy(MemoEntry Function() capture) {
    _snapshot = capture;
    _changed();
  }

  void _changed() {
    _version++;
    _state(MemoSaveState.editing);
    _timer?.cancel();
    if (automatic) {
      _timer = Timer(const Duration(milliseconds: 400), () {
        unawaited(flush().catchError((Object _) {}));
      });
    }
  }

  Future<void> flush() async {
    _timer?.cancel();
    final previous = _writing;
    if (previous != null) {
      await previous;
      if (dirty) await flush();
      return;
    }
    if (!dirty) return;
    final writing = _drain();
    _writing = writing;
    try {
      await writing;
    } finally {
      if (identical(_writing, writing)) _writing = null;
    }
  }

  Future<void> _drain() async {
    try {
      while (dirty) {
        final version = _version;
        final snapshot = value!;
        _state(MemoSaveState.saving);
        await save(snapshot);
        _savedVersion = version;
      }
      _state(MemoSaveState.saved);
    } catch (error) {
      _state(MemoSaveState.failed);
      // 已知业务错误只传递固定错误码，编辑器据此显示可操作的提示。
      if (error is StateError && error.message == 'MEMO_ORDER_CAPACITY') {
        rethrow;
      }
      // 不携带正文或底层数据库错误。
      throw StateError('MEMO_SAVE_FAILED');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
