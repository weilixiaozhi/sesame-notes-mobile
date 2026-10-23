//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_memo_books_by_memo_book_id_calendar_counts200_response_days_inner.g.dart';

/// GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner
///
/// Properties:
/// * [date]
/// * [count]
@BuiltValue()
abstract class GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner
    implements
        Built<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner,
            GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'count')
  int get count;

  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner._();

  factory GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner(
          [void updates(
              GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder
                  b)]) =
      _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>
      get serializer =>
          _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerSerializer();
}

class _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerSerializer
    implements
        PrimitiveSerializer<
            GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner> {
  @override
  final Iterable<Type> types = const [
    GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner,
    _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner
  ];

  @override
  final String wireName =
      r'GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
    );
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner object, {
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
    required GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
          break;
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder();
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
