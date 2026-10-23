//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/day_book.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_day_books200_response.g.dart';

/// GetSyncDayBooks200Response
///
/// Properties:
/// * [dayBooks]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncDayBooks200Response
    implements
        Built<GetSyncDayBooks200Response, GetSyncDayBooks200ResponseBuilder> {
  @BuiltValueField(wireName: r'day_books')
  BuiltList<DayBook> get dayBooks;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncDayBooks200Response._();

  factory GetSyncDayBooks200Response(
          [void updates(GetSyncDayBooks200ResponseBuilder b)]) =
      _$GetSyncDayBooks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncDayBooks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncDayBooks200Response> get serializer =>
      _$GetSyncDayBooks200ResponseSerializer();
}

class _$GetSyncDayBooks200ResponseSerializer
    implements PrimitiveSerializer<GetSyncDayBooks200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncDayBooks200Response,
    _$GetSyncDayBooks200Response
  ];

  @override
  final String wireName = r'GetSyncDayBooks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncDayBooks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day_books';
    yield serializers.serialize(
      object.dayBooks,
      specifiedType: const FullType(BuiltList, [FullType(DayBook)]),
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
    GetSyncDayBooks200Response object, {
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
    required GetSyncDayBooks200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day_books':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(DayBook)]),
          ) as BuiltList<DayBook>;
          result.dayBooks.replace(valueDes);
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
  GetSyncDayBooks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncDayBooks200ResponseBuilder();
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
