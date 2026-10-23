//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_permission_catalog200_response_identities_inner.g.dart';

/// GetAdminPermissionCatalog200ResponseIdentitiesInner
///
/// Properties:
/// * [value]
/// * [label]
@BuiltValue()
abstract class GetAdminPermissionCatalog200ResponseIdentitiesInner
    implements
        Built<GetAdminPermissionCatalog200ResponseIdentitiesInner,
            GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder> {
  @BuiltValueField(wireName: r'value')
  String get value;

  @BuiltValueField(wireName: r'label')
  String get label;

  GetAdminPermissionCatalog200ResponseIdentitiesInner._();

  factory GetAdminPermissionCatalog200ResponseIdentitiesInner(
          [void updates(
              GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder b)]) =
      _$GetAdminPermissionCatalog200ResponseIdentitiesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminPermissionCatalog200ResponseIdentitiesInner>
      get serializer =>
          _$GetAdminPermissionCatalog200ResponseIdentitiesInnerSerializer();
}

class _$GetAdminPermissionCatalog200ResponseIdentitiesInnerSerializer
    implements
        PrimitiveSerializer<
            GetAdminPermissionCatalog200ResponseIdentitiesInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminPermissionCatalog200ResponseIdentitiesInner,
    _$GetAdminPermissionCatalog200ResponseIdentitiesInner
  ];

  @override
  final String wireName =
      r'GetAdminPermissionCatalog200ResponseIdentitiesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponseIdentitiesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminPermissionCatalog200ResponseIdentitiesInner object, {
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
    required GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.value = valueDes;
          break;
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminPermissionCatalog200ResponseIdentitiesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder();
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
