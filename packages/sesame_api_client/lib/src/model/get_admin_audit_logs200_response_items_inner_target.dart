//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_audit_logs200_response_items_inner_target.g.dart';

/// GetAdminAuditLogs200ResponseItemsInnerTarget
///
/// Properties:
/// * [type]
/// * [id]
@BuiltValue()
abstract class GetAdminAuditLogs200ResponseItemsInnerTarget
    implements
        Built<GetAdminAuditLogs200ResponseItemsInnerTarget,
            GetAdminAuditLogs200ResponseItemsInnerTargetBuilder> {
  @BuiltValueField(wireName: r'type')
  String get type;

  @BuiltValueField(wireName: r'id')
  String get id;

  GetAdminAuditLogs200ResponseItemsInnerTarget._();

  factory GetAdminAuditLogs200ResponseItemsInnerTarget(
          [void updates(
              GetAdminAuditLogs200ResponseItemsInnerTargetBuilder b)]) =
      _$GetAdminAuditLogs200ResponseItemsInnerTarget;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAuditLogs200ResponseItemsInnerTargetBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAuditLogs200ResponseItemsInnerTarget>
      get serializer =>
          _$GetAdminAuditLogs200ResponseItemsInnerTargetSerializer();
}

class _$GetAdminAuditLogs200ResponseItemsInnerTargetSerializer
    implements
        PrimitiveSerializer<GetAdminAuditLogs200ResponseItemsInnerTarget> {
  @override
  final Iterable<Type> types = const [
    GetAdminAuditLogs200ResponseItemsInnerTarget,
    _$GetAdminAuditLogs200ResponseItemsInnerTarget
  ];

  @override
  final String wireName = r'GetAdminAuditLogs200ResponseItemsInnerTarget';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAuditLogs200ResponseItemsInnerTarget object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAuditLogs200ResponseItemsInnerTarget object, {
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
    required GetAdminAuditLogs200ResponseItemsInnerTargetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAuditLogs200ResponseItemsInnerTarget deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAuditLogs200ResponseItemsInnerTargetBuilder();
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
