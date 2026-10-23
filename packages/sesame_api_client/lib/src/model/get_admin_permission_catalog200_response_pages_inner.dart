//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_permission_catalog200_response_pages_inner.g.dart';

/// GetAdminPermissionCatalog200ResponsePagesInner
///
/// Properties:
/// * [id]
/// * [label]
/// * [path]
/// * [requiredPermissions]
/// * [assignable]
@BuiltValue()
abstract class GetAdminPermissionCatalog200ResponsePagesInner
    implements
        Built<GetAdminPermissionCatalog200ResponsePagesInner,
            GetAdminPermissionCatalog200ResponsePagesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'required_permissions')
  BuiltList<String> get requiredPermissions;

  @BuiltValueField(wireName: r'assignable')
  bool get assignable;

  GetAdminPermissionCatalog200ResponsePagesInner._();

  factory GetAdminPermissionCatalog200ResponsePagesInner(
          [void updates(
              GetAdminPermissionCatalog200ResponsePagesInnerBuilder b)]) =
      _$GetAdminPermissionCatalog200ResponsePagesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminPermissionCatalog200ResponsePagesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminPermissionCatalog200ResponsePagesInner>
      get serializer =>
          _$GetAdminPermissionCatalog200ResponsePagesInnerSerializer();
}

class _$GetAdminPermissionCatalog200ResponsePagesInnerSerializer
    implements
        PrimitiveSerializer<GetAdminPermissionCatalog200ResponsePagesInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminPermissionCatalog200ResponsePagesInner,
    _$GetAdminPermissionCatalog200ResponsePagesInner
  ];

  @override
  final String wireName = r'GetAdminPermissionCatalog200ResponsePagesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponsePagesInner object, {
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
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    yield r'required_permissions';
    yield serializers.serialize(
      object.requiredPermissions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'assignable';
    yield serializers.serialize(
      object.assignable,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponsePagesInner object, {
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
    required GetAdminPermissionCatalog200ResponsePagesInnerBuilder result,
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
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'required_permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.requiredPermissions.replace(valueDes);
          break;
        case r'assignable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.assignable = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminPermissionCatalog200ResponsePagesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminPermissionCatalog200ResponsePagesInnerBuilder();
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
