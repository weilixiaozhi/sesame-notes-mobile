//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_status200_response_users.dart';
import 'package:sesame_api_client/src/model/get_admin_status200_response_ledgers.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_status200_response.g.dart';

/// GetAdminStatus200Response
///
/// Properties:
/// * [users]
/// * [ledgers]
/// * [devices]
/// * [syncChanges]
/// * [auditLogs]
@BuiltValue()
abstract class GetAdminStatus200Response
    implements
        Built<GetAdminStatus200Response, GetAdminStatus200ResponseBuilder> {
  @BuiltValueField(wireName: r'users')
  GetAdminStatus200ResponseUsers get users;

  @BuiltValueField(wireName: r'ledgers')
  GetAdminStatus200ResponseLedgers get ledgers;

  @BuiltValueField(wireName: r'devices')
  GetAdminStatus200ResponseLedgers get devices;

  @BuiltValueField(wireName: r'sync_changes')
  GetAdminStatus200ResponseLedgers get syncChanges;

  @BuiltValueField(wireName: r'audit_logs')
  GetAdminStatus200ResponseLedgers get auditLogs;

  GetAdminStatus200Response._();

  factory GetAdminStatus200Response(
          [void updates(GetAdminStatus200ResponseBuilder b)]) =
      _$GetAdminStatus200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminStatus200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminStatus200Response> get serializer =>
      _$GetAdminStatus200ResponseSerializer();
}

class _$GetAdminStatus200ResponseSerializer
    implements PrimitiveSerializer<GetAdminStatus200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminStatus200Response,
    _$GetAdminStatus200Response
  ];

  @override
  final String wireName = r'GetAdminStatus200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminStatus200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(GetAdminStatus200ResponseUsers),
    );
    yield r'ledgers';
    yield serializers.serialize(
      object.ledgers,
      specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
    );
    yield r'devices';
    yield serializers.serialize(
      object.devices,
      specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
    );
    yield r'sync_changes';
    yield serializers.serialize(
      object.syncChanges,
      specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
    );
    yield r'audit_logs';
    yield serializers.serialize(
      object.auditLogs,
      specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminStatus200Response object, {
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
    required GetAdminStatus200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminStatus200ResponseUsers),
          ) as GetAdminStatus200ResponseUsers;
          result.users.replace(valueDes);
          break;
        case r'ledgers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
          ) as GetAdminStatus200ResponseLedgers;
          result.ledgers.replace(valueDes);
          break;
        case r'devices':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
          ) as GetAdminStatus200ResponseLedgers;
          result.devices.replace(valueDes);
          break;
        case r'sync_changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
          ) as GetAdminStatus200ResponseLedgers;
          result.syncChanges.replace(valueDes);
          break;
        case r'audit_logs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminStatus200ResponseLedgers),
          ) as GetAdminStatus200ResponseLedgers;
          result.auditLogs.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminStatus200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminStatus200ResponseBuilder();
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
