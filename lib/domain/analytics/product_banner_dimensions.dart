import 'package:uuid/uuid.dart';

/// 横幅统计只携带记录身份、固定位置、实际素材来源和修订号。
class ProductBannerDimensions {
  /// 内置图片版本固定为零，远端版本来自已成功显示的配置。
  const ProductBannerDimensions({
    required this.id,
    required this.slot,
    required this.source,
    required this.version,
  });
  final String id;
  final String slot;
  final String source;
  final int version;

  static const fields = {
    'banner_id',
    'banner_slot',
    'banner_source',
    'banner_version',
  };
  static const slots = {'fitness-plan-library', 'fitness-template-library'};

  /// 受控位置与素材版本必须一致，不能把默认图片归入远端素材。
  bool get isValid =>
      slots.contains(slot) &&
      (source == 'builtin' && version == 0 && id == 'builtin:$slot' ||
          source == 'remote' &&
              Uuid.isValidUUID(fromString: id) &&
              version >= 1 &&
              version <= 2147483647);

  /// 每个位置只在其实际宿主页面采集。
  String get pageId =>
      slot == 'fitness-plan-library' ? 'fitness.plans' : 'fitness.templates';

  /// 同次页面访问的曝光去重键，不含账号或业务内容。
  (String, String, String, int) get key => (id, slot, source, version);

  /// 只输出规范允许的四个维度，离线恢复使用同一白名单。
  Map<String, Object> toJson() => {
    'banner_id': id,
    'banner_slot': slot,
    'banner_source': source,
    'banner_version': version,
  };

  /// 完整且合法的维度才能进入重试队列，部分字段不能静默补齐。
  static ProductBannerDimensions? parse(Map row) {
    final slot = row['banner_slot'];
    final id = row['banner_id'];
    final source = row['banner_source'];
    final version = row['banner_version'];
    if (id is! String ||
        slot is! String ||
        source is! String ||
        version is! int) {
      return null;
    }
    final value = ProductBannerDimensions(
      id: id,
      slot: slot,
      source: source,
      version: version,
    );
    return value.isValid ? value : null;
  }

  /// 横幅事件要求完整维度，其他事件不能夹带横幅字段。
  static bool validEvent(String? name, Object? pageId, Map row) {
    if (name != 'banner_impression' && name != 'banner_click') {
      return !fields.any(row.containsKey);
    }
    final value = parse(row);
    return value != null && value.pageId == pageId;
  }
}
