//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_users_by_user_id_devices200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_users_by_user_id_devices200_response.g.dart';

/// GetAdminUsersByUserIdDevices200Response
///
/// Properties:
/// * [items]
/// * [page]
/// * [pageSize]
/// * [total]
@BuiltValue()
abstract class GetAdminUsersByUserIdDevices200Response
    implements
        Built<GetAdminUsersByUserIdDevices200Response,
            GetAdminUsersByUserIdDevices200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminUsersByUserIdDevices200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'page')
  int get page;

  @BuiltValueField(wireName: r'page_size')
  int get pageSize;

  @BuiltValueField(wireName: r'total')
  int get total;

  GetAdminUsersByUserIdDevices200Response._();

  factory GetAdminUsersByUserIdDevices200Response(
          [void updates(GetAdminUsersByUserIdDevices200ResponseBuilder b)]) =
      _$GetAdminUsersByUserIdDevices200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminUsersByUserIdDevices200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminUsersByUserIdDevices200Response> get serializer =>
      _$GetAdminUsersByUserIdDevices200ResponseSerializer();
}

class _$GetAdminUsersByUserIdDevices200ResponseSerializer
    implements PrimitiveSerializer<GetAdminUsersByUserIdDevices200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminUsersByUserIdDevices200Response,
    _$GetAdminUsersByUserIdDevices200Response
  ];

  @override
  final String wireName = r'GetAdminUsersByUserIdDevices200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminUsersByUserIdDevices200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminUsersByUserIdDevices200ResponseItemsInner)]),
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
    GetAdminUsersByUserIdDevices200Response object, {
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
    required GetAdminUsersByUserIdDevices200ResponseBuilder result,
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
                [FullType(GetAdminUsersByUserIdDevices200ResponseItemsInner)]),
          ) as BuiltList<GetAdminUsersByUserIdDevices200ResponseItemsInner>;
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
  GetAdminUsersByUserIdDevices200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminUsersByUserIdDevices200ResponseBuilder();
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
