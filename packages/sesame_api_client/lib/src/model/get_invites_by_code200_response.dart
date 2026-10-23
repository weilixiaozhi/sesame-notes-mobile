//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_invites_by_code200_response.g.dart';

/// GetInvitesByCode200Response
///
/// Properties:
/// * [ledgerId]
/// * [ledgerName]
/// * [role]
/// * [expiresAt]
@BuiltValue()
abstract class GetInvitesByCode200Response
    implements
        Built<GetInvitesByCode200Response, GetInvitesByCode200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'ledger_name')
  String get ledgerName;

  @BuiltValueField(wireName: r'role')
  GetInvitesByCode200ResponseRoleEnum get role;
  // enum roleEnum {  editor,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  GetInvitesByCode200Response._();

  factory GetInvitesByCode200Response(
          [void updates(GetInvitesByCode200ResponseBuilder b)]) =
      _$GetInvitesByCode200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetInvitesByCode200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetInvitesByCode200Response> get serializer =>
      _$GetInvitesByCode200ResponseSerializer();
}

class _$GetInvitesByCode200ResponseSerializer
    implements PrimitiveSerializer<GetInvitesByCode200Response> {
  @override
  final Iterable<Type> types = const [
    GetInvitesByCode200Response,
    _$GetInvitesByCode200Response
  ];

  @override
  final String wireName = r'GetInvitesByCode200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetInvitesByCode200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_name';
    yield serializers.serialize(
      object.ledgerName,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(GetInvitesByCode200ResponseRoleEnum),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetInvitesByCode200Response object, {
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
    required GetInvitesByCode200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'ledger_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerName = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetInvitesByCode200ResponseRoleEnum),
          ) as GetInvitesByCode200ResponseRoleEnum;
          result.role = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetInvitesByCode200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetInvitesByCode200ResponseBuilder();
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

class GetInvitesByCode200ResponseRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editor')
  static const GetInvitesByCode200ResponseRoleEnum editor =
      _$getInvitesByCode200ResponseRoleEnum_editor;

  static Serializer<GetInvitesByCode200ResponseRoleEnum> get serializer =>
      _$getInvitesByCode200ResponseRoleEnumSerializer;

  const GetInvitesByCode200ResponseRoleEnum._(String name) : super(name);

  static BuiltSet<GetInvitesByCode200ResponseRoleEnum> get values =>
      _$getInvitesByCode200ResponseRoleEnumValues;
  static GetInvitesByCode200ResponseRoleEnum valueOf(String name) =>
      _$getInvitesByCode200ResponseRoleEnumValueOf(name);
}
