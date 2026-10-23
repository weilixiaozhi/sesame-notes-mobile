//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_memo_books_by_memo_book_id_calendar_counts200_response_days_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_memo_books_by_memo_book_id_calendar_counts200_response.g.dart';

/// GetMemoBooksByMemoBookIdCalendarCounts200Response
///
/// Properties:
/// * [days]
@BuiltValue()
abstract class GetMemoBooksByMemoBookIdCalendarCounts200Response
    implements
        Built<GetMemoBooksByMemoBookIdCalendarCounts200Response,
            GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder> {
  @BuiltValueField(wireName: r'days')
  BuiltList<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>
      get days;

  GetMemoBooksByMemoBookIdCalendarCounts200Response._();

  factory GetMemoBooksByMemoBookIdCalendarCounts200Response(
          [void updates(
              GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder b)]) =
      _$GetMemoBooksByMemoBookIdCalendarCounts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMemoBooksByMemoBookIdCalendarCounts200Response>
      get serializer =>
          _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseSerializer();
}

class _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseSerializer
    implements
        PrimitiveSerializer<GetMemoBooksByMemoBookIdCalendarCounts200Response> {
  @override
  final Iterable<Type> types = const [
    GetMemoBooksByMemoBookIdCalendarCounts200Response,
    _$GetMemoBooksByMemoBookIdCalendarCounts200Response
  ];

  @override
  final String wireName = r'GetMemoBooksByMemoBookIdCalendarCounts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMemoBooksByMemoBookIdCalendarCounts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(BuiltList, [
        FullType(GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetMemoBooksByMemoBookIdCalendarCounts200Response object, {
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
    required GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner)
            ]),
          ) as BuiltList<
              GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>;
          result.days.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder();
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
