//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_admin_accounts_by_admin_id_identity_request.g.dart';

/// PutAdminAccountsByAdminIdIdentityRequest
///
/// Properties:
/// * [version]
/// * [identityType]
/// * [reason]
@BuiltValue()
abstract class PutAdminAccountsByAdminIdIdentityRequest
    implements
        Built<PutAdminAccountsByAdminIdIdentityRequest,
            PutAdminAccountsByAdminIdIdentityRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'identity_type')
  PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum get identityType;
  // enum identityTypeEnum {  super_admin,  standard_user,  };

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PutAdminAccountsByAdminIdIdentityRequest._();

  factory PutAdminAccountsByAdminIdIdentityRequest(
          [void updates(PutAdminAccountsByAdminIdIdentityRequestBuilder b)]) =
      _$PutAdminAccountsByAdminIdIdentityRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutAdminAccountsByAdminIdIdentityRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutAdminAccountsByAdminIdIdentityRequest> get serializer =>
      _$PutAdminAccountsByAdminIdIdentityRequestSerializer();
}

class _$PutAdminAccountsByAdminIdIdentityRequestSerializer
    implements PrimitiveSerializer<PutAdminAccountsByAdminIdIdentityRequest> {
  @override
  final Iterable<Type> types = const [
    PutAdminAccountsByAdminIdIdentityRequest,
    _$PutAdminAccountsByAdminIdIdentityRequest
  ];

  @override
  final String wireName = r'PutAdminAccountsByAdminIdIdentityRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutAdminAccountsByAdminIdIdentityRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'identity_type';
    yield serializers.serialize(
      object.identityType,
      specifiedType: const FullType(
          PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PutAdminAccountsByAdminIdIdentityRequest object, {
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
    required PutAdminAccountsByAdminIdIdentityRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'identity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum),
          ) as PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum;
          result.identityType = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PutAdminAccountsByAdminIdIdentityRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutAdminAccountsByAdminIdIdentityRequestBuilder();
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

class PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'super_admin')
  static const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
      superAdmin =
      _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_superAdmin;
  @BuiltValueEnumConst(wireName: r'standard_user')
  static const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
      standardUser =
      _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_standardUser;

  static Serializer<PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>
      get serializer =>
          _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumSerializer;

  const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>
      get values =>
          _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumValues;
  static PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum valueOf(
          String name) =>
      _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumValueOf(name);
}
