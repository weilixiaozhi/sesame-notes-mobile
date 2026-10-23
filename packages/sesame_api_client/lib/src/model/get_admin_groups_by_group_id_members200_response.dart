//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_groups_by_group_id_members200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_groups_by_group_id_members200_response.g.dart';

/// GetAdminGroupsByGroupIdMembers200Response
///
/// Properties:
/// * [items]
/// * [page]
/// * [pageSize]
/// * [total]
@BuiltValue()
abstract class GetAdminGroupsByGroupIdMembers200Response
    implements
        Built<GetAdminGroupsByGroupIdMembers200Response,
            GetAdminGroupsByGroupIdMembers200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminGroupsByGroupIdMembers200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total')
  int get total;

  GetAdminGroupsByGroupIdMembers200Response._();

  factory GetAdminGroupsByGroupIdMembers200Response(
          [void updates(GetAdminGroupsByGroupIdMembers200ResponseBuilder b)]) =
      _$GetAdminGroupsByGroupIdMembers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminGroupsByGroupIdMembers200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminGroupsByGroupIdMembers200Response> get serializer =>
      _$GetAdminGroupsByGroupIdMembers200ResponseSerializer();
}

class _$GetAdminGroupsByGroupIdMembers200ResponseSerializer
    implements PrimitiveSerializer<GetAdminGroupsByGroupIdMembers200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminGroupsByGroupIdMembers200Response,
    _$GetAdminGroupsByGroupIdMembers200Response
  ];

  @override
  final String wireName = r'GetAdminGroupsByGroupIdMembers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminGroupsByGroupIdMembers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminGroupsByGroupIdMembers200ResponseItemsInner)]),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminGroupsByGroupIdMembers200Response object, {
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
    required GetAdminGroupsByGroupIdMembers200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetAdminGroupsByGroupIdMembers200ResponseItemsInner)
            ]),
          ) as BuiltList<GetAdminGroupsByGroupIdMembers200ResponseItemsInner>;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminGroupsByGroupIdMembers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminGroupsByGroupIdMembers200ResponseBuilder();
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
