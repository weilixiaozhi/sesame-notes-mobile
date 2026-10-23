import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/text_validation.dart';

void main() {
  group('登录 / 注册凭证校验', () {
    test('手机号为空时拒绝提交，密码是否填写都不放行', () {
      expect(
        validateCredentialsForm(phone: '', password: 'secret123'),
        AuthFormError.phoneRequired,
      );
      expect(
        validateCredentialsForm(phone: '', password: ''),
        AuthFormError.phoneRequired,
      );
      expect(
        validateCredentialsForm(
          phone: '',
          password: 'pass-1',
          confirmPassword: 'other',
        ),
        AuthFormError.phoneRequired,
      );
    });

    test('密码为空时拒绝提交', () {
      expect(
        validateCredentialsForm(phone: '13800138000', password: ''),
        AuthFormError.passwordRequired,
      );
    });

    test('注册确认密码不一致时拒绝提交，一致时放行', () {
      expect(
        validateCredentialsForm(
          phone: '13800138000',
          password: 'pass-1',
          confirmPassword: 'pass-2',
        ),
        AuthFormError.passwordMismatch,
      );
      expect(
        validateCredentialsForm(
          phone: '13800138000',
          password: 'pass-1',
          confirmPassword: 'pass-1',
        ),
        isNull,
      );
    });

    test('登录没有确认密码输入框时只校验手机号与密码', () {
      expect(
        validateCredentialsForm(phone: '13800138000', password: 'secret123'),
        isNull,
      );
    });
  });

  group('修改密码校验', () {
    test('允许单字符、纯字母、纯数字与 128 字符密码，并保留原文', () {
      for (final password in ['1', 'abcdefgh', '12345678', 'a' * 128, ' a ']) {
        expect(
          validatePasswordChangeForm(
            currentPassword: 'old-pass-1',
            newPassword: password,
            confirmPassword: password,
          ),
          isNull,
          reason: '长度 ${password.length} 的合法密码应允许提交',
        );
      }
    });

    test('当前密码为空、新密码为空、两次不一致分别被拦截', () {
      expect(
        validatePasswordChangeForm(
          currentPassword: '',
          newPassword: 'abc12345',
          confirmPassword: 'abc12345',
        ),
        AuthFormError.currentPasswordRequired,
      );
      expect(
        validatePasswordChangeForm(
          currentPassword: 'old-pass-1',
          newPassword: '',
          confirmPassword: '',
        ),
        AuthFormError.newPasswordRequired,
      );
      expect(
        validatePasswordChangeForm(
          currentPassword: 'old-pass-1',
          newPassword: 'abc12345',
          confirmPassword: 'abc12346',
        ),
        AuthFormError.passwordConfirmMismatch,
      );
      expect(
        validatePasswordChangeForm(
          currentPassword: 'old-pass-1',
          newPassword: 'abc12345',
          confirmPassword: 'abc12345',
        ),
        isNull,
      );
    });

    test('新密码为空时优先报告必填问题，即使两次输入也不一致', () {
      expect(
        validatePasswordChangeForm(
          currentPassword: 'old-pass-1',
          newPassword: '',
          confirmPassword: 'different',
        ),
        AuthFormError.newPasswordRequired,
      );
    });

    test('当前密码与新密码都执行 128 字符上限', () {
      for (final current in [false, true]) {
        expect(
          validatePasswordChangeForm(
            currentPassword: current ? 'a' * 129 : 'current',
            newPassword: current ? 'next' : 'a' * 129,
            confirmPassword: current ? 'next' : 'a' * 129,
          ),
          AuthFormError.passwordTooLong,
        );
      }
    });

    test('密码长度与网页表单一致按 UTF-16 计数，确认时不修剪空白', () {
      expect(
        validatePasswordChangeForm(
          currentPassword: 'current',
          newPassword: '😀' * 65,
          confirmPassword: '😀' * 65,
        ),
        AuthFormError.passwordTooLong,
      );
      expect(
        validatePasswordChangeForm(
          currentPassword: 'current',
          newPassword: ' next ',
          confirmPassword: 'next',
        ),
        AuthFormError.passwordConfirmMismatch,
      );
    });
  });
}
