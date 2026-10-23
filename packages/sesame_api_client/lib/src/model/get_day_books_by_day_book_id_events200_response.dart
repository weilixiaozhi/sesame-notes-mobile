//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/day_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_day_books_by_day_book_id_events200_response.g.dart';

/// GetDayBooksByDayBookIdEvents200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetDayBooksByDayBookIdEvents200Response
    implements
        Built<GetDayBooksByDayBookIdEvents200Response,
            GetDayBooksByDayBookIdEvents200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<DayEvent> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetDayBooksByDayBookIdEvents200Response._();

  factory GetDayBooksByDayBookIdEvents200Response(
          [void updates(GetDayBooksByDayBookIdEvents200ResponseBuilder b)]) =
      _$GetDayBooksByDayBookIdEvents200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetDayBooksByDayBookIdEvents200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetDayBooksByDayBookIdEvents200Response> get serializer =>
      _$GetDayBooksByDayBookIdEvents200ResponseSerializer();
}

class _$GetDayBooksByDayBookIdEvents200ResponseSerializer
    implements PrimitiveSerializer<GetDayBooksByDayBookIdEvents200Response> {
  @override
  final Iterable<Type> types = const [
    GetDayBooksByDayBookIdEvents200Response,
    _$GetDayBooksByDayBookIdEvents200Response
  ];

  @override
  final String wireName = r'GetDayBooksByDayBookIdEvents200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetDayBooksByDayBookIdEvents200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(DayEvent)]),
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
    GetDayBooksByDayBookIdEvents200Response object, {
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
    required GetDayBooksByDayBookIdEvents200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DayEvent)]),
          ) as BuiltList<DayEvent>;
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
  GetDayBooksByDayBookIdEvents200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetDayBooksByDayBookIdEvents200ResponseBuilder();
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
