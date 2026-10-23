//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_official_exercises200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_exercises200_response.g.dart';

/// ListOfficialExercises200Response
///
/// Properties:
/// * [items]
/// * [page]
/// * [pageSize]
/// * [total]
/// * [nextCursor]
@BuiltValue()
abstract class ListOfficialExercises200Response
    implements
        Built<ListOfficialExercises200Response,
            ListOfficialExercises200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListOfficialExercises200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ListOfficialExercises200Response._();

  factory ListOfficialExercises200Response(
          [void updates(ListOfficialExercises200ResponseBuilder b)]) =
      _$ListOfficialExercises200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialExercises200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialExercises200Response> get serializer =>
      _$ListOfficialExercises200ResponseSerializer();
}

class _$ListOfficialExercises200ResponseSerializer
    implements PrimitiveSerializer<ListOfficialExercises200Response> {
  @override
  final Iterable<Type> types = const [
    ListOfficialExercises200Response,
    _$ListOfficialExercises200Response
  ];

  @override
  final String wireName = r'ListOfficialExercises200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialExercises200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(ListOfficialExercises200ResponseItemsInner)]),
    );
    yield r'page';
    yield serializers.serialize(
      object.page,
      specifiedType: const FullType(int),
    );
    yield r'page_size';
    yield serializers.serialize(
      object.pageSize,
      specifiedType: const FullType(int),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
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
    ListOfficialExercises200Response object, {
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
    required ListOfficialExercises200ResponseBuilder result,
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
                [FullType(ListOfficialExercises200ResponseItemsInner)]),
          ) as BuiltList<ListOfficialExercises200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'page':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.page = valueDes;
          break;
        case r'page_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageSize = valueDes;
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
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
  ListOfficialExercises200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialExercises200ResponseBuilder();
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
