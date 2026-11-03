//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_transaction_edit_history200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_transaction_edit_history200_response.g.dart';

/// GetTransactionEditHistory200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetTransactionEditHistory200Response
    implements
        Built<GetTransactionEditHistory200Response,
            GetTransactionEditHistory200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetTransactionEditHistory200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetTransactionEditHistory200Response._();

  factory GetTransactionEditHistory200Response(
          [void updates(GetTransactionEditHistory200ResponseBuilder b)]) =
      _$GetTransactionEditHistory200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetTransactionEditHistory200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetTransactionEditHistory200Response> get serializer =>
      _$GetTransactionEditHistory200ResponseSerializer();
}

class _$GetTransactionEditHistory200ResponseSerializer
    implements PrimitiveSerializer<GetTransactionEditHistory200Response> {
  @override
  final Iterable<Type> types = const [
    GetTransactionEditHistory200Response,
    _$GetTransactionEditHistory200Response
  ];

  @override
  final String wireName = r'GetTransactionEditHistory200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetTransactionEditHistory200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(GetTransactionEditHistory200ResponseItemsInner)]),
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
    GetTransactionEditHistory200Response object, {
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
    required GetTransactionEditHistory200ResponseBuilder result,
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
                [FullType(GetTransactionEditHistory200ResponseItemsInner)]),
          ) as BuiltList<GetTransactionEditHistory200ResponseItemsInner>;
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
  GetTransactionEditHistory200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetTransactionEditHistory200ResponseBuilder();
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
