import 'dart:typed_data';

/// 服务器可配置的固定入口位置，内置素材始终随应用分发。
enum AppBannerSlot {
  fitnessPlanLibrary(
    'fitness-plan-library',
    'assets/fitness/plan-library-banner.png',
    AppBannerTarget.fitnessPlanLibrary,
  ),
  fitnessTemplateLibrary(
    'fitness-template-library',
    'assets/fitness/template-library-banner.png',
    AppBannerTarget.fitnessTemplateLibrary,
  );

  /// 每个位置绑定独立的图片和默认跳转目标。
  const AppBannerSlot(this.id, this.assetPath, this.defaultTarget);
  final String id;
  final String assetPath;
  final AppBannerTarget defaultTarget;

  /// 未注册的位置不进入应用入口目录。
  static AppBannerSlot? parse(Object? value) =>
      values.where((slot) => slot.id == value).firstOrNull;
}

/// 远端配置只能选择已实现且无需参数的页面，不能执行任意地址。
enum AppBannerTarget {
  fitnessPlanLibrary('fitness-plan-library'),
  fitnessTemplateLibrary('fitness-template-library'),
  fitnessExercises('fitness-exercises'),
  fitnessPlans('fitness-plans'),
  fitnessTemplates('fitness-templates');

  /// 跳转标识是两端共享的受控协议值。
  const AppBannerTarget(this.id);
  final String id;

  /// 未知目标交给入口恢复默认行为。
  static AppBannerTarget? parse(Object? value) =>
      values.where((target) => target.id == value).firstOrNull;
}

/// 只有已完整校验和解码的图片才能与跳转目标一起交给页面。
class ResolvedAppBanner {
  /// 图片字节与目标形成一个不可拆分的展示结果。
  const ResolvedAppBanner({required this.bytes, required this.target});
  final Uint8List bytes;
  final AppBannerTarget target;
}
