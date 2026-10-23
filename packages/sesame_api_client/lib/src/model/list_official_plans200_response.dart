//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_official_plans200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_plans200_response.g.dart';

/// ListOfficialPlans200Response
///
/// Properties:
/// * [items]
/// * [page]
/// * [pageSize]
/// * [total]
/// * [nextCursor]
@BuiltValue()
abstract class ListOfficialPlans200Response
    implements
        Built<ListOfficialPlans200Response,
            ListOfficialPlans200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListOfficialPlans200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ListOfficialPlans200Response._();

  factory ListOfficialPlans200Response(
          [void updates(ListOfficialPlans200ResponseBuilder b)]) =
      _$ListOfficialPlans200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialPlans200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialPlans200Response> get serializer =>
      _$ListOfficialPlans200ResponseSerializer();
}

class _$ListOfficialPlans200ResponseSerializer
    implements PrimitiveSerializer<ListOfficialPlans200Response> {
  @override
  final Iterable<Type> types = const [
    ListOfficialPlans200Response,
    _$ListOfficialPlans200Response
  ];

  @override
  final String wireName = r'ListOfficialPlans200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialPlans200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(ListOfficialPlans200ResponseItemsInner)]),
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
    ListOfficialPlans200Response object, {
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
    required ListOfficialPlans200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(ListOfficialPlans200ResponseItemsInner)]),
          ) as BuiltList<ListOfficialPlans200ResponseItemsInner>;
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
  ListOfficialPlans200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialPlans200ResponseBuilder();
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
