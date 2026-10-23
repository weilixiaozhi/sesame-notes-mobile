//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_members200_response_inner.g.dart';

/// GetLedgersByLedgerIdMembers200ResponseInner
///
/// Properties:
/// * [userId]
/// * [memberId]
/// * [status]
/// * [linkedAccountId]
/// * [sesameNumber]
/// * [displayName]
/// * [avatarUrl]
/// * [avatarVersion]
/// * [role]
/// * [joinedAt]
@BuiltValue()
abstract class GetLedgersByLedgerIdMembers200ResponseInner
    implements
        Built<GetLedgersByLedgerIdMembers200ResponseInner,
            GetLedgersByLedgerIdMembers200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'member_id')
  String get memberId;

  @BuiltValueField(wireName: r'status')
  GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum get status;
  // enum statusEnum {  ACTIVE,  LEFT,  REMOVED,  };

  @BuiltValueField(wireName: r'linked_account_id')
  String get linkedAccountId;

  @BuiltValueField(wireName: r'sesame_number')
  String? get sesameNumber;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'role')
  GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum get role;
  // enum roleEnum {  owner,  editor,  };

  @BuiltValueField(wireName: r'joined_at')
  DateTime get joinedAt;

  GetLedgersByLedgerIdMembers200ResponseInner._();

  factory GetLedgersByLedgerIdMembers200ResponseInner(
          [void updates(
              GetLedgersByLedgerIdMembers200ResponseInnerBuilder b)]) =
      _$GetLedgersByLedgerIdMembers200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetLedgersByLedgerIdMembers200ResponseInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdMembers200ResponseInner>
      get serializer =>
          _$GetLedgersByLedgerIdMembers200ResponseInnerSerializer();
}

class _$GetLedgersByLedgerIdMembers200ResponseInnerSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdMembers200ResponseInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdMembers200ResponseInner,
    _$GetLedgersByLedgerIdMembers200ResponseInner
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdMembers200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdMembers200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'member_id';
    yield serializers.serialize(
      object.memberId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType:
          const FullType(GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum),
    );
    yield r'linked_account_id';
    yield serializers.serialize(
      object.linkedAccountId,
      specifiedType: const FullType(String),
    );
    yield r'sesame_number';
    yield object.sesameNumber == null
        ? null
        : serializers.serialize(
            object.sesameNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'display_name';
    yield object.displayName == null
        ? null
        : serializers.serialize(
            object.displayName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'avatar_url';
    yield object.avatarUrl == null
        ? null
        : serializers.serialize(
            object.avatarUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'avatar_version';
    yield serializers.serialize(
      object.avatarVersion,
      specifiedType: const FullType(int),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType:
          const FullType(GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum),
    );
    yield r'joined_at';
    yield serializers.serialize(
      object.joinedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdMembers200ResponseInner object, {
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
    required GetLedgersByLedgerIdMembers200ResponseInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum),
          ) as GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'linked_account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.linkedAccountId = valueDes;
          break;
        case r'sesame_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sesameNumber = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'avatar_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avatarVersion = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum),
          ) as GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum;
          result.role = valueDes;
          break;
        case r'joined_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.joinedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdMembers200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdMembers200ResponseInnerBuilder();
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

class GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum ACTIVE =
      _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'LEFT')
  static const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum LEFT =
      _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_LEFT;
  @BuiltValueEnumConst(wireName: r'REMOVED')
  static const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum REMOVED =
      _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_REMOVED;

  static Serializer<GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>
      get serializer =>
          _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumSerializer;

  const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum._(String name)
      : super(name);

  static BuiltSet<GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>
      get values =>
          _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumValues;
  static GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum valueOf(
          String name) =>
      _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumValueOf(name);
}

class GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'owner')
  static const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum owner =
      _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_owner;
  @BuiltValueEnumConst(wireName: r'editor')
  static const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum editor =
      _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_editor;

  static Serializer<GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>
      get serializer =>
          _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumSerializer;

  const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum._(String name)
      : super(name);

  static BuiltSet<GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>
      get values => _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumValues;
  static GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum valueOf(
          String name) =>
      _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumValueOf(name);
}
