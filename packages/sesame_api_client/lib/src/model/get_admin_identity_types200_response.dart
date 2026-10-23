//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_identity_types200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_identity_types200_response.g.dart';

/// GetAdminIdentityTypes200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class GetAdminIdentityTypes200Response
    implements
        Built<GetAdminIdentityTypes200Response,
            GetAdminIdentityTypes200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminIdentityTypes200ResponseItemsInner> get items;

  GetAdminIdentityTypes200Response._();

  factory GetAdminIdentityTypes200Response(
          [void updates(GetAdminIdentityTypes200ResponseBuilder b)]) =
      _$GetAdminIdentityTypes200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminIdentityTypes200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminIdentityTypes200Response> get serializer =>
      _$GetAdminIdentityTypes200ResponseSerializer();
}

class _$GetAdminIdentityTypes200ResponseSerializer
    implements PrimitiveSerializer<GetAdminIdentityTypes200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminIdentityTypes200Response,
    _$GetAdminIdentityTypes200Response
  ];

  @override
  final String wireName = r'GetAdminIdentityTypes200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminIdentityTypes200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminIdentityTypes200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminIdentityTypes200Response object, {
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
    required GetAdminIdentityTypes200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminIdentityTypes200ResponseItemsInner)]),
          ) as BuiltList<GetAdminIdentityTypes200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminIdentityTypes200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminIdentityTypes200ResponseBuilder();
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
