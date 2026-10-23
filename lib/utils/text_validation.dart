/// 普通名称统一上限；按 Unicode 码点计数，正文和密码不使用此约束。
const maxNameLength = 100;

/// 密码按输入原文校验，长度单位与网页端的 UTF-16 字符单元一致。
const maxPasswordLength = 128;
const nameWhitespace =
    '\u0009\u000A\u000B\u000C\u000D\u0020\u0085\u00A0\u1680'
    '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A'
    '\u2028\u2029\u202F\u205F\u3000\uFEFF';
final _nameCharacters = RegExp.escape(nameWhitespace);
final _nameEdges = RegExp('^[$_nameCharacters]+|[$_nameCharacters]+\$');

/// 保留名称内部空白，禁止不可见名称和损坏的 Unicode。
String normalizeName(String value) {
  final name = value.replaceAll(_nameEdges, '');
  if (!hasVisibleText(name) ||
      name.runes.length > maxNameLength ||
      name.contains('\u0000')) {
    throw const FormatException('INVALID_NAME');
  }
  return name;
}

bool isValidName(String value) {
  try {
    normalizeName(value);
    return true;
  } on FormatException {
    return false;
  }
}

bool hasVisibleText(String value) =>
    isWellFormedText(value) &&
    RegExp(
      r'[^\s\u0000-\u001f\u007f-\u009f\u00ad\u034f\u061c\u115f\u1160\u17b4\u17b5\u180e\u200b-\u200f\u202a-\u202e\u2060-\u206f\u2800\u3164\ufeff\ufe00-\ufe0f\uffa0]',
      unicode: true,
    ).hasMatch(value);

/// 认证表单的校验失败原因；页面按值映射稳定文案，返回 null 表示允许提交。
enum AuthFormError {
  /// 手机号为空
  phoneRequired,

  /// 登录 / 注册密码为空
  passwordRequired,

  /// 注册两次输入的密码不一致
  passwordMismatch,

  /// 修改密码时当前密码为空
  currentPasswordRequired,

  /// 当前密码或新密码超过长度上限
  passwordTooLong,

  /// 新密码为空
  newPasswordRequired,

  /// 修改密码两次输入的新密码不一致
  passwordConfirmMismatch,
}

/// 登录 / 注册凭证校验：手机号非空 → 密码非空 → 两次输入一致。
///
/// [confirmPassword] 为 null 时跳过一致性检查（登录页没有确认密码输入框）。
/// 返回 null 表示允许发起认证请求，校验顺序与页面提示一一对应。
AuthFormError? validateCredentialsForm({
  required String phone,
  required String password,
  String? confirmPassword,
}) {
  if (phone.isEmpty) return AuthFormError.phoneRequired;
  if (password.isEmpty) return AuthFormError.passwordRequired;
  if (confirmPassword != null && password != confirmPassword) {
    return AuthFormError.passwordMismatch;
  }
  return null;
}

/// 修改密码表单校验：当前密码、新密码均为 1–128 个字符，确认密码须一致。
AuthFormError? validatePasswordChangeForm({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) {
  if (currentPassword.isEmpty) return AuthFormError.currentPasswordRequired;
  if (currentPassword.length > maxPasswordLength) {
    return AuthFormError.passwordTooLong;
  }
  if (newPassword.isEmpty) return AuthFormError.newPasswordRequired;
  if (newPassword.length > maxPasswordLength) {
    return AuthFormError.passwordTooLong;
  }
  if (newPassword != confirmPassword) {
    return AuthFormError.passwordConfirmMismatch;
  }
  return null;
}

bool isWellFormedText(String value) {
  for (var i = 0; i < value.length; i++) {
    final unit = value.codeUnitAt(i);
    if (unit >= 0xdc00 && unit <= 0xdfff) return false;
    if (unit >= 0xd800 && unit <= 0xdbff) {
      if (++i == value.length) return false;
      final next = value.codeUnitAt(i);
      if (next < 0xdc00 || next > 0xdfff) return false;
    }
  }
  return true;
}
