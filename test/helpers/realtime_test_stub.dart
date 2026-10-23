/// 实时通知测试替身：隔离 widget 测试中的真实网络与定时器副作用。
///
/// 背景：登录/登出会驱动 [realtimeCoordinatorProvider] 启停，生产实现会真实
/// 请求 WS 票据并在失败后按指数退避重试。widget 测试若不隔离，既会发出真实
/// 网络请求，又会在 FakeAsync 下留下挂起的重试定时器，被判定为测试失败。
/// 因此凡是不以实时通知为测试对象的页面测试，都应装配 [realtimeNoopOverride]。
library;

import 'package:sesame_notes/shared/providers/realtime_providers.dart';

/// 不发起任何网络请求的实时协调器。
class NoopRealtimeCoordinator extends RealtimeCoordinator {
  NoopRealtimeCoordinator(super.ref);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

/// 隔离实时通知网络副作用的 provider 覆盖项。
final realtimeNoopOverride = realtimeCoordinatorProvider.overrideWith(
  NoopRealtimeCoordinator.new,
);
