/// adapter 后端描述符：声明后端身份、配置字段和校验规则。
///
/// 设计意图：核心包不 import 任何 adapter，也不认识任何后端字段名。adapter
/// 在自注册时提交本描述符，核心只做两件事：
/// 1. 按 [CloudBackend.fields] 把配置拆成“凭据字段进安全存储 / 其余进
///    SharedPreferences”，并据此渲染通用表单；
/// 2. 按 [CloudBackend.validate] 判定配置是否可用。
///
/// 由此新增后端只需新增 adapter 包，核心包零改动。
library;

/// 配置字段的输入与存储类型。
enum CloudConfigFieldKind {
  /// 普通文本：明文落 SharedPreferences。
  text,

  /// 凭据文本（密码 / 密钥）：落系统安全存储，不进 SharedPreferences。
  secret,

  /// 整数：明文落 SharedPreferences，表单走数字键盘。
  number,

  /// 开关：明文落 SharedPreferences，表单渲染 Switch。
  boolean,
}

/// adapter 声明的单个配置字段。
///
/// [key] 是 [CloudServiceConfig.settings] 里的键，核心只搬运不解释；
/// [labelKey] 指向宿主 App 的本地化资源，adapter 自身不持有任何文案。
class CloudConfigField {
  const CloudConfigField({
    required this.key,
    required this.labelKey,
    this.kind = CloudConfigFieldKind.text,
    this.isRequired = false,
    this.defaultValue,
  });

  /// [CloudServiceConfig.settings] 中的键。
  final String key;

  /// 宿主 App 本地化资源的键名（adapter 不持有文案，核心也不解释）。
  final String labelKey;

  /// 输入与存储类型。
  final CloudConfigFieldKind kind;

  /// 是否必填（缺省校验器要求非空）。
  final bool isRequired;

  /// 未配置时的默认值（目前用于布尔开关）。
  final Object? defaultValue;

  /// 是否属于凭据（决定落安全存储还是 SharedPreferences）。
  bool get isSecret => kind == CloudConfigFieldKind.secret;
}

/// 后端描述符：adapter 自注册时提交，核心不认识任何具体后端。
class CloudBackend {
  const CloudBackend({
    required this.id,
    required this.displayName,
    required this.fields,
    this.validate,
  });

  /// 稳定后端 ID：同时用作注册表键与持久化键后缀。
  final String id;

  /// 列表页展示名。
  final String displayName;

  /// 该后端的配置字段声明（顺序即表单顺序）。
  final List<CloudConfigField> fields;

  /// 后端自有校验；省略时按“必填字段非空”判定。
  final bool Function(Map<String, dynamic> settings)? validate;

  /// 该键是否由本后端声明。
  bool hasField(String key) => fields.any((f) => f.key == key);

  /// 该键是否属于本后端声明的凭据字段。
  bool isSecretField(String key) =>
      fields.any((f) => f.key == key && f.isSecret);

  /// 先按字段类型验证配置，再执行后端提供的业务校验。
  bool validateSettings(Map<String, dynamic> settings) {
    try {
      for (final field in fields) {
        final value = settings[field.key] ?? field.defaultValue;
        if (value == null) {
          if (field.isRequired) return false;
          continue;
        }
        final valid = switch (field.kind) {
          CloudConfigFieldKind.text ||
          CloudConfigFieldKind.secret =>
            value is String && (!field.isRequired || value.trim().isNotEmpty),
          CloudConfigFieldKind.number => value is int,
          CloudConfigFieldKind.boolean => value is bool,
        };
        if (!valid) return false;
      }
      return validate?.call(settings) ?? true;
    } catch (_) {
      // 外部配置或后端校验器不能使配置页崩溃，错误配置保持不可激活。
      return false;
    }
  }
}
