//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/memo_entry.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_memo_books_by_memo_book_id_entries200_response.g.dart';

/// GetMemoBooksByMemoBookIdEntries200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetMemoBooksByMemoBookIdEntries200Response
    implements
        Built<GetMemoBooksByMemoBookIdEntries200Response,
            GetMemoBooksByMemoBookIdEntries200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<MemoEntry> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetMemoBooksByMemoBookIdEntries200Response._();

  factory GetMemoBooksByMemoBookIdEntries200Response(
          [void updates(GetMemoBooksByMemoBookIdEntries200ResponseBuilder b)]) =
      _$GetMemoBooksByMemoBookIdEntries200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetMemoBooksByMemoBookIdEntries200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetMemoBooksByMemoBookIdEntries200Response>
      get serializer =>
          _$GetMemoBooksByMemoBookIdEntries200ResponseSerializer();
}

class _$GetMemoBooksByMemoBookIdEntries200ResponseSerializer
    implements PrimitiveSerializer<GetMemoBooksByMemoBookIdEntries200Response> {
  @override
  final Iterable<Type> types = const [
    GetMemoBooksByMemoBookIdEntries200Response,
    _$GetMemoBooksByMemoBookIdEntries200Response
  ];

  @override
  final String wireName = r'GetMemoBooksByMemoBookIdEntries200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetMemoBooksByMemoBookIdEntries200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(MemoEntry)]),
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
    GetMemoBooksByMemoBookIdEntries200Response object, {
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
    required GetMemoBooksByMemoBookIdEntries200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MemoEntry)]),
          ) as BuiltList<MemoEntry>;
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
  GetMemoBooksByMemoBookIdEntries200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetMemoBooksByMemoBookIdEntries200ResponseBuilder();
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
