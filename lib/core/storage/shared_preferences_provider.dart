import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 系统偏好存储的统一读取入口，可在测试和应用装配时替换。
///
/// 插件保留进程级缓存；所有调用者共享同一个 Provider 身份，
/// 底层设施无需引用业务装配或其他转发出口。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
