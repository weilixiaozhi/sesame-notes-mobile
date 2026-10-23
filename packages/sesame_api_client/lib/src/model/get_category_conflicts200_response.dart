//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category_conflict.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_category_conflicts200_response.g.dart';

/// GetCategoryConflicts200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
/// * [hasMore]
@BuiltValue()
abstract class GetCategoryConflicts200Response
    implements
        Built<GetCategoryConflicts200Response,
            GetCategoryConflicts200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<CategoryConflict> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  GetCategoryConflicts200Response._();

  factory GetCategoryConflicts200Response(
          [void updates(GetCategoryConflicts200ResponseBuilder b)]) =
      _$GetCategoryConflicts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetCategoryConflicts200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetCategoryConflicts200Response> get serializer =>
      _$GetCategoryConflicts200ResponseSerializer();
}

class _$GetCategoryConflicts200ResponseSerializer
    implements PrimitiveSerializer<GetCategoryConflicts200Response> {
  @override
  final Iterable<Type> types = const [
    GetCategoryConflicts200Response,
    _$GetCategoryConflicts200Response
  ];

  @override
  final String wireName = r'GetCategoryConflicts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetCategoryConflicts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(CategoryConflict)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null
        ? null
        : serializers.serialize(
            object.nextCursor,
            specifiedType: const FullType.nullable(String),
          );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetCategoryConflicts200Response object, {
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
    required GetCategoryConflicts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(CategoryConflict)]),
          ) as BuiltList<CategoryConflict>;
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
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetCategoryConflicts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetCategoryConflicts200ResponseBuilder();
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
