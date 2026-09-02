//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_register_request_device.g.dart';

/// PostAuthRegisterRequestDevice
///
/// Properties:
/// * [installationId]
/// * [name]
/// * [platform]
/// * [appVersion]
/// * [osVersion]
/// * [deviceModel]
@BuiltValue()
abstract class PostAuthRegisterRequestDevice
    implements
        Built<PostAuthRegisterRequestDevice,
            PostAuthRegisterRequestDeviceBuilder> {
  @BuiltValueField(wireName: r'installation_id')
  String get installationId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'platform')
  String get platform;

  @BuiltValueField(wireName: r'app_version')
  String? get appVersion;

  @BuiltValueField(wireName: r'os_version')
  String? get osVersion;

  @BuiltValueField(wireName: r'device_model')
  String? get deviceModel;

  PostAuthRegisterRequestDevice._();

  factory PostAuthRegisterRequestDevice(
          [void updates(PostAuthRegisterRequestDeviceBuilder b)]) =
      _$PostAuthRegisterRequestDevice;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthRegisterRequestDeviceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthRegisterRequestDevice> get serializer =>
      _$PostAuthRegisterRequestDeviceSerializer();
}

class _$PostAuthRegisterRequestDeviceSerializer
    implements PrimitiveSerializer<PostAuthRegisterRequestDevice> {
  @override
  final Iterable<Type> types = const [
    PostAuthRegisterRequestDevice,
    _$PostAuthRegisterRequestDevice
  ];

  @override
  final String wireName = r'PostAuthRegisterRequestDevice';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthRegisterRequestDevice object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'installation_id';
    yield serializers.serialize(
      object.installationId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(String),
    );
    if (object.appVersion != null) {
      yield r'app_version';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.osVersion != null) {
      yield r'os_version';
      yield serializers.serialize(
        object.osVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceModel != null) {
      yield r'device_model';
      yield serializers.serialize(
        object.deviceModel,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthRegisterRequestDevice object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostAuthRegisterRequestDeviceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'installation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.installationId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.platform = valueDes;
          break;
        case r'app_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.appVersion = valueDes;
          break;
        case r'os_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.osVersion = valueDes;
          break;
        case r'device_model':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deviceModel = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthRegisterRequestDevice deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthRegisterRequestDeviceBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
