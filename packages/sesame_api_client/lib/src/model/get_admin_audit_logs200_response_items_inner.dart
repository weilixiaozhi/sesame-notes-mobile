//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_audit_logs200_response_items_inner_target.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_audit_logs200_response_items_inner.g.dart';

/// GetAdminAuditLogs200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [actor]
/// * [action]
/// * [target]
/// * [requestId]
/// * [ip]
/// * [createdAt]
@BuiltValue()
abstract class GetAdminAuditLogs200ResponseItemsInner
    implements
        Built<GetAdminAuditLogs200ResponseItemsInner,
            GetAdminAuditLogs200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'actor')
  String get actor;

  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'target')
  GetAdminAuditLogs200ResponseItemsInnerTarget get target;

  @BuiltValueField(wireName: r'request_id')
  String get requestId;

  @BuiltValueField(wireName: r'ip')
  String? get ip;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  GetAdminAuditLogs200ResponseItemsInner._();

  factory GetAdminAuditLogs200ResponseItemsInner(
          [void updates(GetAdminAuditLogs200ResponseItemsInnerBuilder b)]) =
      _$GetAdminAuditLogs200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAuditLogs200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAuditLogs200ResponseItemsInner> get serializer =>
      _$GetAdminAuditLogs200ResponseItemsInnerSerializer();
}

class _$GetAdminAuditLogs200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<GetAdminAuditLogs200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAuditLogs200ResponseItemsInner,
    _$GetAdminAuditLogs200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminAuditLogs200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAuditLogs200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'actor';
    yield serializers.serialize(
      object.actor,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType:
          const FullType(GetAdminAuditLogs200ResponseItemsInnerTarget),
    );
    yield r'request_id';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    yield r'ip';
    yield object.ip == null
        ? null
        : serializers.serialize(
            object.ip,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAuditLogs200ResponseItemsInner object, {
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
    required GetAdminAuditLogs200ResponseItemsInnerBuilder result,
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
        case r'actor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actor = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminAuditLogs200ResponseItemsInnerTarget),
          ) as GetAdminAuditLogs200ResponseItemsInnerTarget;
          result.target.replace(valueDes);
          break;
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'ip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ip = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAuditLogs200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAuditLogs200ResponseItemsInnerBuilder();
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
