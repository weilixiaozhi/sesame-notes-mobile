import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudProfileCache 按账号键控', () {
    test('资料按 user_id 隔离存取', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = CloudProfileCache(prefs);

      await cache.write(
        const CloudProfile(
          userId: 'user-a',
          sesameNumber: '111111111',
          displayName: 'A',
          phoneMasked: '+86 138****8000',
        ),
      );
      await cache.write(
        const CloudProfile(userId: 'user-b', sesameNumber: '222222222'),
      );

      expect(cache.read('user-a')!.displayName, 'A');
      expect(cache.read('user-b')!.sesameNumber, '222222222');
      expect(cache.read('user-c'), isNull);

      await cache.clear('user-a');
      expect(cache.read('user-a'), isNull);
      expect(cache.read('user-b'), isNotNull, reason: '清除 A 不影响 B');
    });

    test('损坏缓存按缺失处理', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sesame_notes_cloud_profile_user-x', 'bad-json');
      final cache = CloudProfileCache(prefs);
      expect(cache.read('user-x'), isNull);
    });
  });

  group('CloudProfile 序列化', () {
    test('toJson/fromJson 往返', () {
      const profile = CloudProfile(
        userId: 'u',
        sesameNumber: '123456789',
        displayName: '芝麻仔000001',
        avatarVersion: 3,
        phone: '+8613800138000',
        phoneMasked: '+86 138****8000',
        gender: 'MALE',
      );
      final decoded = CloudProfile.fromJson(
        jsonDecode(jsonEncode(profile.toJson())) as Map<String, dynamic>,
      )!;
      expect(decoded.userId, 'u');
      expect(decoded.sesameNumber, '123456789');
      expect(decoded.avatarVersion, 3);
      expect(decoded.gender, 'MALE');
      expect(decoded.phone, '+8613800138000');
      expect(decoded.phoneMasked, '+86 138****8000');
    });
  });
}
