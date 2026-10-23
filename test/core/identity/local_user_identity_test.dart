import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/identity/local_user_identity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocalSelfId.resetForTest();
    SharedPreferences.setMockInitialValues({});
  });

  test('并发 getOrCreate 返回同一个身份', () async {
    final results = await Future.wait([
      LocalSelfId.getOrCreate(),
      LocalSelfId.getOrCreate(),
      LocalSelfId.getOrCreate(),
    ]);

    expect(results.toSet(), hasLength(1));
  });

  test('getOrCreate：已有合法 UUID 直接返回且不重写', () async {
    const id = '123e4567-e89b-42d3-a456-426614174000';
    SharedPreferences.setMockInitialValues({LocalSelfId.prefsKey: id});

    expect(await LocalSelfId.getOrCreate(), id);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocalSelfId.prefsKey), id);
  });
}
