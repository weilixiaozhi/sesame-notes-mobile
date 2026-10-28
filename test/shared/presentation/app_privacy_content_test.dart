import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';

/// 应用锁和后台隐私屏共同决定业务内容是否允许展示。
void main() {
  group('遮蔽谓词', () {
    test('应用锁或后台隐私屏任一成立都必须隐藏业务内容', () {
      expect(
        shouldHideAppContent(locked: false, privacyScreen: false),
        isFalse,
      );
      expect(shouldHideAppContent(locked: true, privacyScreen: false), isTrue);
      expect(shouldHideAppContent(locked: false, privacyScreen: true), isTrue);
      expect(shouldHideAppContent(locked: true, privacyScreen: true), isTrue);
    });
  });
}
