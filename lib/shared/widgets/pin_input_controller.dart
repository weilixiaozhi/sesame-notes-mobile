import 'package:flutter/foundation.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 管理四位 PIN 草稿、提交互斥与错误反馈，认证和设置流程由调用页面负责。
class PinInputController extends ChangeNotifier {
  String _digits = '';
  bool _submitting = false;
  bool _hasError = false;
  bool _disposed = false;

  /// 当前输入位数，完整提交前清空草稿，不向视觉组件暴露 PIN 内容。
  int get length => _digits.length;

  /// 错误反馈窗口内的圆点状态。
  bool get hasError => _hasError;

  /// 接收单个数字；达到四位时返回一次性快照并立即锁住后续输入。
  String? addDigit(String digit) {
    if (_disposed || _submitting || !RegExp(r'^[0-9]$').hasMatch(digit)) {
      return null;
    }
    _hasError = false;
    _digits += digit;
    String? completed;
    if (_digits.length == 4) {
      completed = _digits;
      _digits = '';
      // 在页面开始异步认证前取得提交所有权，连点不能生成第二份 PIN。
      _submitting = true;
    }
    notifyListeners();
    return completed;
  }

  /// 删除最后一位草稿；认证及错误反馈期间保持输入互斥。
  void deleteDigit() {
    if (_disposed || _submitting || _digits.isEmpty) return;
    _hasError = false;
    _digits = _digits.substring(0, _digits.length - 1);
    notifyListeners();
  }

  /// 展示有限时间的错误状态，页面销毁后不通知监听者。
  Future<void> showError() async {
    if (_disposed) return;
    _hasError = true;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
    } catch (error, stackTrace) {
      logger.error('PinInput', '等待 PIN 错误反馈失败', error, stackTrace);
      rethrow;
    } finally {
      if (!_disposed) {
        _hasError = false;
        notifyListeners();
      }
    }
  }

  /// 提交与错误反馈全部完成后才释放输入；本方法适合在页面 finally 调用。
  void finishSubmission() {
    if (_disposed) return;
    _submitting = false;
    _hasError = false;
    notifyListeners();
  }

  /// 清理未提交草稿并停止通知，迟到的认证或错误反馈可安全结束。
  @override
  void dispose() {
    _disposed = true;
    _digits = '';
    _submitting = false;
    _hasError = false;
    super.dispose();
  }
}
