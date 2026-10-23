//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/memo_entry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/memo_book.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_memo_books_full200_response.g.dart';

/// GetSyncMemoBooksFull200Response
///
/// Properties:
/// * [memoBook]
/// * [memoEntries]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncMemoBooksFull200Response
    implements
        Built<GetSyncMemoBooksFull200Response,
            GetSyncMemoBooksFull200ResponseBuilder> {
  @BuiltValueField(wireName: r'memo_book')
  MemoBook get memoBook;

  @BuiltValueField(wireName: r'memo_entries')
  BuiltList<MemoEntry> get memoEntries;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncMemoBooksFull200Response._();

  factory GetSyncMemoBooksFull200Response(
          [void updates(GetSyncMemoBooksFull200ResponseBuilder b)]) =
      _$GetSyncMemoBooksFull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncMemoBooksFull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncMemoBooksFull200Response> get serializer =>
      _$GetSyncMemoBooksFull200ResponseSerializer();
}

class _$GetSyncMemoBooksFull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncMemoBooksFull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncMemoBooksFull200Response,
    _$GetSyncMemoBooksFull200Response
  ];

  @override
  final String wireName = r'GetSyncMemoBooksFull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncMemoBooksFull200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'memo_book';
    yield serializers.serialize(
      object.memoBook,
      specifiedType: const FullType(MemoBook),
    );
    yield r'memo_entries';
    yield serializers.serialize(
      object.memoEntries,
      specifiedType: const FullType(BuiltList, [FullType(MemoEntry)]),
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
    GetSyncMemoBooksFull200Response object, {
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
    required GetSyncMemoBooksFull200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'memo_book':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemoBook),
          ) as MemoBook;
          result.memoBook.replace(valueDes);
          break;
        case r'memo_entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MemoEntry)]),
          ) as BuiltList<MemoEntry>;
          result.memoEntries.replace(valueDes);
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
  GetSyncMemoBooksFull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncMemoBooksFull200ResponseBuilder();
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
