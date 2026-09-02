//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_status200_response_users.g.dart';

/// GetAdminStatus200ResponseUsers
///
/// Properties:
/// * [total]
/// * [enabled]
/// * [admins]
@BuiltValue()
abstract class GetAdminStatus200ResponseUsers
    implements
        Built<GetAdminStatus200ResponseUsers,
            GetAdminStatus200ResponseUsersBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'enabled')
  int get enabled;

  @BuiltValueField(wireName: r'admins')
  int get admins;

  GetAdminStatus200ResponseUsers._();

  factory GetAdminStatus200ResponseUsers(
          [void updates(GetAdminStatus200ResponseUsersBuilder b)]) =
      _$GetAdminStatus200ResponseUsers;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminStatus200ResponseUsersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminStatus200ResponseUsers> get serializer =>
      _$GetAdminStatus200ResponseUsersSerializer();
}

class _$GetAdminStatus200ResponseUsersSerializer
    implements PrimitiveSerializer<GetAdminStatus200ResponseUsers> {
  @override
  final Iterable<Type> types = const [
    GetAdminStatus200ResponseUsers,
    _$GetAdminStatus200ResponseUsers
  ];

  @override
  final String wireName = r'GetAdminStatus200ResponseUsers';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminStatus200ResponseUsers object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(int),
    );
    yield r'admins';
    yield serializers.serialize(
      object.admins,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminStatus200ResponseUsers object, {
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
    required GetAdminStatus200ResponseUsersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.enabled = valueDes;
          break;
        case r'admins':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.admins = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminStatus200ResponseUsers deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminStatus200ResponseUsersBuilder();
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
