//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_invites200_response_inner.g.dart';

/// GetLedgersByLedgerIdInvites200ResponseInner
///
/// Properties:
/// * [id]
/// * [codePrefix]
/// * [role]
/// * [expiresAt]
/// * [usedAt]
/// * [usedByUserId]
/// * [createdAt]
@BuiltValue()
abstract class GetLedgersByLedgerIdInvites200ResponseInner
    implements
        Built<GetLedgersByLedgerIdInvites200ResponseInner,
            GetLedgersByLedgerIdInvites200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code_prefix')
  String get codePrefix;

  @BuiltValueField(wireName: r'role')
  GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum get role;
  // enum roleEnum {  editor,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'used_at')
  DateTime? get usedAt;

  @BuiltValueField(wireName: r'used_by_user_id')
  String? get usedByUserId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  GetLedgersByLedgerIdInvites200ResponseInner._();

  factory GetLedgersByLedgerIdInvites200ResponseInner(
          [void updates(
              GetLedgersByLedgerIdInvites200ResponseInnerBuilder b)]) =
      _$GetLedgersByLedgerIdInvites200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetLedgersByLedgerIdInvites200ResponseInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdInvites200ResponseInner>
      get serializer =>
          _$GetLedgersByLedgerIdInvites200ResponseInnerSerializer();
}

class _$GetLedgersByLedgerIdInvites200ResponseInnerSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdInvites200ResponseInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdInvites200ResponseInner,
    _$GetLedgersByLedgerIdInvites200ResponseInner
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdInvites200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdInvites200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code_prefix';
    yield serializers.serialize(
      object.codePrefix,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType:
          const FullType(GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'used_at';
    yield object.usedAt == null
        ? null
        : serializers.serialize(
            object.usedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'used_by_user_id';
    yield object.usedByUserId == null
        ? null
        : serializers.serialize(
            object.usedByUserId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdInvites200ResponseInner object, {
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
    required GetLedgersByLedgerIdInvites200ResponseInnerBuilder result,
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
        case r'code_prefix':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.codePrefix = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum),
          ) as GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum;
          result.role = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'used_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.usedAt = valueDes;
          break;
        case r'used_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.usedByUserId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdInvites200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdInvites200ResponseInnerBuilder();
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

class GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editor')
  static const GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum editor =
      _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnum_editor;

  static Serializer<GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>
      get serializer =>
          _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumSerializer;

  const GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum._(String name)
      : super(name);

  static BuiltSet<GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>
      get values => _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumValues;
  static GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum valueOf(
          String name) =>
      _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumValueOf(name);
}
