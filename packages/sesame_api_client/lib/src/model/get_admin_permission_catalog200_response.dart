//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_permission_catalog200_response_permissions_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_permission_catalog200_response_pages_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_permission_catalog200_response_identities_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_permission_catalog200_response.g.dart';

/// GetAdminPermissionCatalog200Response
///
/// Properties:
/// * [permissions]
/// * [pages]
/// * [identities]
@BuiltValue()
abstract class GetAdminPermissionCatalog200Response
    implements
        Built<GetAdminPermissionCatalog200Response,
            GetAdminPermissionCatalog200ResponseBuilder> {
  @BuiltValueField(wireName: r'permissions')
  BuiltList<GetAdminPermissionCatalog200ResponsePermissionsInner>
      get permissions;

  @BuiltValueField(wireName: r'pages')
  BuiltList<GetAdminPermissionCatalog200ResponsePagesInner> get pages;

  @BuiltValueField(wireName: r'identities')
  BuiltList<GetAdminPermissionCatalog200ResponseIdentitiesInner> get identities;

  GetAdminPermissionCatalog200Response._();

  factory GetAdminPermissionCatalog200Response(
          [void updates(GetAdminPermissionCatalog200ResponseBuilder b)]) =
      _$GetAdminPermissionCatalog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminPermissionCatalog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminPermissionCatalog200Response> get serializer =>
      _$GetAdminPermissionCatalog200ResponseSerializer();
}

class _$GetAdminPermissionCatalog200ResponseSerializer
    implements PrimitiveSerializer<GetAdminPermissionCatalog200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminPermissionCatalog200Response,
    _$GetAdminPermissionCatalog200Response
  ];

  @override
  final String wireName = r'GetAdminPermissionCatalog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminPermissionCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminPermissionCatalog200ResponsePermissionsInner)]),
    );
    yield r'pages';
    yield serializers.serialize(
      object.pages,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminPermissionCatalog200ResponsePagesInner)]),
    );
    yield r'identities';
    yield serializers.serialize(
      object.identities,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminPermissionCatalog200ResponseIdentitiesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminPermissionCatalog200Response object, {
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
    required GetAdminPermissionCatalog200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetAdminPermissionCatalog200ResponsePermissionsInner)
            ]),
          ) as BuiltList<GetAdminPermissionCatalog200ResponsePermissionsInner>;
          result.permissions.replace(valueDes);
          break;
        case r'pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminPermissionCatalog200ResponsePagesInner)]),
          ) as BuiltList<GetAdminPermissionCatalog200ResponsePagesInner>;
          result.pages.replace(valueDes);
          break;
        case r'identities':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetAdminPermissionCatalog200ResponseIdentitiesInner)
            ]),
          ) as BuiltList<GetAdminPermissionCatalog200ResponseIdentitiesInner>;
          result.identities.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminPermissionCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminPermissionCatalog200ResponseBuilder();
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
