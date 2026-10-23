//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_identity_types200_response_items_inner.g.dart';

/// GetAdminIdentityTypes200ResponseItemsInner
///
/// Properties:
/// * [value]
/// * [label]
@BuiltValue()
abstract class GetAdminIdentityTypes200ResponseItemsInner
    implements
        Built<GetAdminIdentityTypes200ResponseItemsInner,
            GetAdminIdentityTypes200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'value')
  GetAdminIdentityTypes200ResponseItemsInnerValueEnum get value;
  // enum valueEnum {  super_admin,  standard_user,  };

  @BuiltValueField(wireName: r'label')
  String get label;

  GetAdminIdentityTypes200ResponseItemsInner._();

  factory GetAdminIdentityTypes200ResponseItemsInner(
          [void updates(GetAdminIdentityTypes200ResponseItemsInnerBuilder b)]) =
      _$GetAdminIdentityTypes200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminIdentityTypes200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminIdentityTypes200ResponseItemsInner>
      get serializer =>
          _$GetAdminIdentityTypes200ResponseItemsInnerSerializer();
}

class _$GetAdminIdentityTypes200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<GetAdminIdentityTypes200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminIdentityTypes200ResponseItemsInner,
    _$GetAdminIdentityTypes200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminIdentityTypes200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminIdentityTypes200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType:
          const FullType(GetAdminIdentityTypes200ResponseItemsInnerValueEnum),
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
    GetAdminIdentityTypes200ResponseItemsInner object, {
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
    required GetAdminIdentityTypes200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminIdentityTypes200ResponseItemsInnerValueEnum),
          ) as GetAdminIdentityTypes200ResponseItemsInnerValueEnum;
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
  GetAdminIdentityTypes200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminIdentityTypes200ResponseItemsInnerBuilder();
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

class GetAdminIdentityTypes200ResponseItemsInnerValueEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'super_admin')
  static const GetAdminIdentityTypes200ResponseItemsInnerValueEnum superAdmin =
      _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_superAdmin;
  @BuiltValueEnumConst(wireName: r'standard_user')
  static const GetAdminIdentityTypes200ResponseItemsInnerValueEnum
      standardUser =
      _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_standardUser;

  static Serializer<GetAdminIdentityTypes200ResponseItemsInnerValueEnum>
      get serializer =>
          _$getAdminIdentityTypes200ResponseItemsInnerValueEnumSerializer;

  const GetAdminIdentityTypes200ResponseItemsInnerValueEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminIdentityTypes200ResponseItemsInnerValueEnum>
      get values => _$getAdminIdentityTypes200ResponseItemsInnerValueEnumValues;
  static GetAdminIdentityTypes200ResponseItemsInnerValueEnum valueOf(
          String name) =>
      _$getAdminIdentityTypes200ResponseItemsInnerValueEnumValueOf(name);
}
