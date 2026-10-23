//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_audit_logs200_response_items_inner.g.dart';

/// GetAdminAuditLogs200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [ip]
/// * [createdAt]
/// * [actionLabel]
/// * [actorDisplay]
/// * [targetDisplay]
/// * [summary]
/// * [reason]
@BuiltValue()
abstract class GetAdminAuditLogs200ResponseItemsInner
    implements
        Built<GetAdminAuditLogs200ResponseItemsInner,
            GetAdminAuditLogs200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ip')
  String? get ip;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'action_label')
  String get actionLabel;

  @BuiltValueField(wireName: r'actor_display')
  String? get actorDisplay;

  @BuiltValueField(wireName: r'target_display')
  String? get targetDisplay;

  @BuiltValueField(wireName: r'summary')
  String? get summary;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

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
    yield r'action_label';
    yield serializers.serialize(
      object.actionLabel,
      specifiedType: const FullType(String),
    );
    yield r'actor_display';
    yield object.actorDisplay == null
        ? null
        : serializers.serialize(
            object.actorDisplay,
            specifiedType: const FullType.nullable(String),
          );
    yield r'target_display';
    yield object.targetDisplay == null
        ? null
        : serializers.serialize(
            object.targetDisplay,
            specifiedType: const FullType.nullable(String),
          );
    yield r'summary';
    yield object.summary == null
        ? null
        : serializers.serialize(
            object.summary,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reason';
    yield object.reason == null
        ? null
        : serializers.serialize(
            object.reason,
            specifiedType: const FullType.nullable(String),
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
        case r'action_label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.actionLabel = valueDes;
          break;
        case r'actor_display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.actorDisplay = valueDes;
          break;
        case r'target_display':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetDisplay = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summary = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
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
