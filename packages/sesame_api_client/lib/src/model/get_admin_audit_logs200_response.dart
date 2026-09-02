//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_audit_logs200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_audit_logs200_response.g.dart';

/// GetAdminAuditLogs200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetAdminAuditLogs200Response
    implements
        Built<GetAdminAuditLogs200Response,
            GetAdminAuditLogs200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminAuditLogs200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetAdminAuditLogs200Response._();

  factory GetAdminAuditLogs200Response(
          [void updates(GetAdminAuditLogs200ResponseBuilder b)]) =
      _$GetAdminAuditLogs200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAuditLogs200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAuditLogs200Response> get serializer =>
      _$GetAdminAuditLogs200ResponseSerializer();
}

class _$GetAdminAuditLogs200ResponseSerializer
    implements PrimitiveSerializer<GetAdminAuditLogs200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminAuditLogs200Response,
    _$GetAdminAuditLogs200Response
  ];

  @override
  final String wireName = r'GetAdminAuditLogs200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAuditLogs200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminAuditLogs200ResponseItemsInner)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null
        ? null
        : serializers.serialize(
            object.nextCursor,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAuditLogs200Response object, {
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
    required GetAdminAuditLogs200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(GetAdminAuditLogs200ResponseItemsInner)]),
          ) as BuiltList<GetAdminAuditLogs200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAuditLogs200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAuditLogs200ResponseBuilder();
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
