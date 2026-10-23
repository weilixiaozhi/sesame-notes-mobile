//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_permission_catalog200_response_permissions_inner.g.dart';

/// GetAdminPermissionCatalog200ResponsePermissionsInner
///
/// Properties:
/// * [id]
/// * [label]
/// * [dependencies]
@BuiltValue()
abstract class GetAdminPermissionCatalog200ResponsePermissionsInner
    implements
        Built<GetAdminPermissionCatalog200ResponsePermissionsInner,
            GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'dependencies')
  BuiltList<String> get dependencies;

  GetAdminPermissionCatalog200ResponsePermissionsInner._();

  factory GetAdminPermissionCatalog200ResponsePermissionsInner(
          [void updates(
              GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder b)]) =
      _$GetAdminPermissionCatalog200ResponsePermissionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminPermissionCatalog200ResponsePermissionsInner>
      get serializer =>
          _$GetAdminPermissionCatalog200ResponsePermissionsInnerSerializer();
}

class _$GetAdminPermissionCatalog200ResponsePermissionsInnerSerializer
    implements
        PrimitiveSerializer<
            GetAdminPermissionCatalog200ResponsePermissionsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminPermissionCatalog200ResponsePermissionsInner,
    _$GetAdminPermissionCatalog200ResponsePermissionsInner
  ];

  @override
  final String wireName =
      r'GetAdminPermissionCatalog200ResponsePermissionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponsePermissionsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    yield r'dependencies';
    yield serializers.serialize(
      object.dependencies,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponsePermissionsInner object, {
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
    required GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'dependencies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.dependencies.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminPermissionCatalog200ResponsePermissionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder();
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
