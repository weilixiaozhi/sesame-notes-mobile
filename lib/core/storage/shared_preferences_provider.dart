import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 获取的统一出口（core 叶子定义）。
///
/// getInstance() 本身已有进程级缓存，本 provider 的价值在于把获取动作收拢到
/// 一个可 override 的节点：装配层统一经它读，测试可整体替换注入内存实例，
/// 统一经本 Provider 获取插件单例，避免各处直取。
///
/// 声明于 core/storage 的原因：core/api（云资料缓存等）也需要该出口，
/// 若留在装配层会造成 core → shared/providers 上行依赖；这里作为横切叶子，
/// shared/providers/shared_preferences_provider.dart 仅做 re-export 保持调用方不变。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});
