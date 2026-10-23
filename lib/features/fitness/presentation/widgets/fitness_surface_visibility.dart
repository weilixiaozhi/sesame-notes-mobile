import 'package:flutter/widgets.dart';

/// 跟踪同一训练的界面实例，通知不依赖具体页面或弹层类。
class FitnessSurfaceVisibility extends ChangeNotifier {
  /// 同标识可以同时存在于多个导航实例，关闭其中一个不会清除其余实例。
  FitnessSurfaceVisibility();

  final _counts = <String, int>{};
  bool _disposed = false;

  /// 查询目标训练是否仍有可见实例。
  bool isOpen(String id) => (_counts[id] ?? 0) > 0;

  /// 登记界面实例，帧结束后才触发依赖界面重建。
  void open(String id) {
    _counts[id] = (_counts[id] ?? 0) + 1;
    _publish();
  }

  /// 移除一个实例，保留同标识的其他界面。
  void close(String id) {
    final count = _counts[id] ?? 0;
    if (count <= 1) {
      _counts.remove(id);
    } else {
      _counts[id] = count - 1;
    }
    _publish();
  }

  /// 避免在页面构建和释放期间同步重建监听者。
  void _publish() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
    // 独立状态变更也会发生在空闲阶段，必须确保回调有下一帧可以执行。
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  /// 已排队的帧回调在释放后不再通知。
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// 训练详情与休息弹层分别保持独立可见性。
final fitnessWorkoutVisibility = FitnessSurfaceVisibility();
final fitnessRestSheetVisibility = FitnessSurfaceVisibility();
