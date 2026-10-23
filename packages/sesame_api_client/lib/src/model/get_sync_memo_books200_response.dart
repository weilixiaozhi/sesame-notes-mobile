//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_sync_memo_books200_response_memo_books_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_memo_books200_response.g.dart';

/// GetSyncMemoBooks200Response
///
/// Properties:
/// * [memoBooks]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncMemoBooks200Response
    implements
        Built<GetSyncMemoBooks200Response, GetSyncMemoBooks200ResponseBuilder> {
  @BuiltValueField(wireName: r'memo_books')
  BuiltList<GetSyncMemoBooks200ResponseMemoBooksInner> get memoBooks;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncMemoBooks200Response._();

  factory GetSyncMemoBooks200Response(
          [void updates(GetSyncMemoBooks200ResponseBuilder b)]) =
      _$GetSyncMemoBooks200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncMemoBooks200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncMemoBooks200Response> get serializer =>
      _$GetSyncMemoBooks200ResponseSerializer();
}

class _$GetSyncMemoBooks200ResponseSerializer
    implements PrimitiveSerializer<GetSyncMemoBooks200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncMemoBooks200Response,
    _$GetSyncMemoBooks200Response
  ];

  @override
  final String wireName = r'GetSyncMemoBooks200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncMemoBooks200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'memo_books';
    yield serializers.serialize(
      object.memoBooks,
      specifiedType: const FullType(
          BuiltList, [FullType(GetSyncMemoBooks200ResponseMemoBooksInner)]),
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
    GetSyncMemoBooks200Response object, {
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
    required GetSyncMemoBooks200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'memo_books':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetSyncMemoBooks200ResponseMemoBooksInner)]),
          ) as BuiltList<GetSyncMemoBooks200ResponseMemoBooksInner>;
          result.memoBooks.replace(valueDes);
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
  GetSyncMemoBooks200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncMemoBooks200ResponseBuilder();
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
