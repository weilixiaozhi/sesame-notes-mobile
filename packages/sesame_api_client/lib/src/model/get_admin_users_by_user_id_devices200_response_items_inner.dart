//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_users_by_user_id_devices200_response_items_inner.g.dart';

/// GetAdminUsersByUserIdDevices200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [platform]
/// * [appVersion]
/// * [osVersion]
/// * [deviceModel]
/// * [lastIp]
/// * [createdAt]
/// * [lastSeenAt]
/// * [revokedAt]
@BuiltValue()
abstract class GetAdminUsersByUserIdDevices200ResponseItemsInner
    implements
        Built<GetAdminUsersByUserIdDevices200ResponseItemsInner,
            GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

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

  @BuiltValueField(wireName: r'last_ip')
  String? get lastIp;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'last_seen_at')
  DateTime get lastSeenAt;

  @BuiltValueField(wireName: r'revoked_at')
  DateTime? get revokedAt;

  GetAdminUsersByUserIdDevices200ResponseItemsInner._();

  factory GetAdminUsersByUserIdDevices200ResponseItemsInner(
          [void updates(
              GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder b)]) =
      _$GetAdminUsersByUserIdDevices200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminUsersByUserIdDevices200ResponseItemsInner>
      get serializer =>
          _$GetAdminUsersByUserIdDevices200ResponseItemsInnerSerializer();
}

class _$GetAdminUsersByUserIdDevices200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<GetAdminUsersByUserIdDevices200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminUsersByUserIdDevices200ResponseItemsInner,
    _$GetAdminUsersByUserIdDevices200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminUsersByUserIdDevices200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminUsersByUserIdDevices200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
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
    yield r'app_version';
    yield object.appVersion == null
        ? null
        : serializers.serialize(
            object.appVersion,
            specifiedType: const FullType.nullable(String),
          );
    yield r'os_version';
    yield object.osVersion == null
        ? null
        : serializers.serialize(
            object.osVersion,
            specifiedType: const FullType.nullable(String),
          );
    yield r'device_model';
    yield object.deviceModel == null
        ? null
        : serializers.serialize(
            object.deviceModel,
            specifiedType: const FullType.nullable(String),
          );
    yield r'last_ip';
    yield object.lastIp == null
        ? null
        : serializers.serialize(
            object.lastIp,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'last_seen_at';
    yield serializers.serialize(
      object.lastSeenAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'revoked_at';
    yield object.revokedAt == null
        ? null
        : serializers.serialize(
            object.revokedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminUsersByUserIdDevices200ResponseItemsInner object, {
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
    required GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
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
        case r'last_ip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastIp = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'last_seen_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.lastSeenAt = valueDes;
          break;
        case r'revoked_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.revokedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminUsersByUserIdDevices200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminUsersByUserIdDevices200ResponseItemsInnerBuilder();
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
