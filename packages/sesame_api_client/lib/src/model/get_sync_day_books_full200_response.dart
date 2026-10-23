//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/day_book.dart';
import 'package:sesame_api_client/src/model/day_event.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_day_books_full200_response.g.dart';

/// GetSyncDayBooksFull200Response
///
/// Properties:
/// * [dayBook]
/// * [dayEvents]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncDayBooksFull200Response
    implements
        Built<GetSyncDayBooksFull200Response,
            GetSyncDayBooksFull200ResponseBuilder> {
  @BuiltValueField(wireName: r'day_book')
  DayBook get dayBook;

  @BuiltValueField(wireName: r'day_events')
  BuiltList<DayEvent> get dayEvents;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncDayBooksFull200Response._();

  factory GetSyncDayBooksFull200Response(
          [void updates(GetSyncDayBooksFull200ResponseBuilder b)]) =
      _$GetSyncDayBooksFull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncDayBooksFull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncDayBooksFull200Response> get serializer =>
      _$GetSyncDayBooksFull200ResponseSerializer();
}

class _$GetSyncDayBooksFull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncDayBooksFull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncDayBooksFull200Response,
    _$GetSyncDayBooksFull200Response
  ];

  @override
  final String wireName = r'GetSyncDayBooksFull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncDayBooksFull200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day_book';
    yield serializers.serialize(
      object.dayBook,
      specifiedType: const FullType(DayBook),
    );
    yield r'day_events';
    yield serializers.serialize(
      object.dayEvents,
      specifiedType: const FullType(BuiltList, [FullType(DayEvent)]),
    );
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncDayBooksFull200Response object, {
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
    required GetSyncDayBooksFull200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day_book':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DayBook),
          ) as DayBook;
          result.dayBook.replace(valueDes);
          break;
        case r'day_events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DayEvent)]),
          ) as BuiltList<DayEvent>;
          result.dayEvents.replace(valueDes);
          break;
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncDayBooksFull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncDayBooksFull200ResponseBuilder();
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
