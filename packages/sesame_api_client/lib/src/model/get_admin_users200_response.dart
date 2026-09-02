//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_users200_response_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_users200_response.g.dart';

/// GetAdminUsers200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetAdminUsers200Response
    implements
        Built<GetAdminUsers200Response, GetAdminUsers200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminUsers200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetAdminUsers200Response._();

  factory GetAdminUsers200Response(
          [void updates(GetAdminUsers200ResponseBuilder b)]) =
      _$GetAdminUsers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminUsers200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminUsers200Response> get serializer =>
      _$GetAdminUsers200ResponseSerializer();
}

class _$GetAdminUsers200ResponseSerializer
    implements PrimitiveSerializer<GetAdminUsers200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminUsers200Response,
    _$GetAdminUsers200Response
  ];

  @override
  final String wireName = r'GetAdminUsers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminUsers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminUsers200ResponseItemsInner)]),
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
    GetAdminUsers200Response object, {
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
    required GetAdminUsers200ResponseBuilder result,
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
                BuiltList, [FullType(GetAdminUsers200ResponseItemsInner)]),
          ) as BuiltList<GetAdminUsers200ResponseItemsInner>;
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
  GetAdminUsers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminUsers200ResponseBuilder();
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
