import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 后端描述符必须把无效配置作为校验结果，不把类型错误抛给配置页。
void main() {
  const backend = CloudBackend(id: 'typed', displayName: 'Typed', fields: [
    CloudConfigField(key: 'name', labelKey: 'name', isRequired: true),
    CloudConfigField(
        key: 'password',
        labelKey: 'password',
        kind: CloudConfigFieldKind.secret,
        isRequired: true),
    CloudConfigField(
        key: 'port',
        labelKey: 'port',
        kind: CloudConfigFieldKind.number,
        isRequired: true),
    CloudConfigField(
        key: 'enabled',
        labelKey: 'enabled',
        kind: CloudConfigFieldKind.boolean,
        isRequired: true),
  ]);
  const valid = {
    'name': 'service',
    'password': 'secret',
    'port': 0,
    'enabled': false
  };

  test('必填布尔 false 和整数零均有效，错误类型或缺失无效', () {
    expect(backend.validateSettings(valid), isTrue);
    for (final key in valid.keys) {
      expect(backend.validateSettings({...valid}..remove(key)), isFalse);
      expect(backend.validateSettings({...valid, key: <Object>[]}), isFalse);
    }
    for (final value in [1.2, double.nan, double.infinity, '443']) {
      expect(backend.validateSettings({...valid, 'port': value}), isFalse);
    }
    expect(backend.validateSettings({...valid, 'name': '   '}), isFalse);
  });

  test('可选类型也受校验，业务校验只能收窄有效配置', () {
    final custom = CloudBackend(
        id: 'custom',
        displayName: 'Custom',
        fields: const [
          CloudConfigField(
              key: 'port', labelKey: 'port', kind: CloudConfigFieldKind.number),
          CloudConfigField(
              key: 'enabled',
              labelKey: 'enabled',
              kind: CloudConfigFieldKind.boolean,
              defaultValue: false,
              isRequired: true),
        ],
        validate: (settings) => settings['port'] != 0);
    expect(custom.validateSettings({}), isTrue);
    expect(custom.validateSettings({'port': '443'}), isFalse);
    expect(custom.validateSettings({'port': 0}), isFalse);
    expect(custom.validateSettings({'port': 443}), isTrue);
  });
}
