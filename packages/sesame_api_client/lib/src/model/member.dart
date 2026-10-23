//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'member.g.dart';

/// Member
///
/// Properties:
/// * [id]
/// * [ledgerId]
/// * [displayName]
/// * [memberType]
/// * [status]
/// * [updatedAt]
@BuiltValue()
abstract class Member implements Built<Member, MemberBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'member_type')
  MemberMemberTypeEnum get memberType;
  // enum memberTypeEnum {  REGISTERED,  PLACEHOLDER,  };

  @BuiltValueField(wireName: r'status')
  MemberStatusEnum get status;
  // enum statusEnum {  ACTIVE,  LEFT,  REMOVED,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  Member._();

  factory Member([void updates(MemberBuilder b)]) = _$Member;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemberBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Member> get serializer => _$MemberSerializer();
}

class _$MemberSerializer implements PrimitiveSerializer<Member> {
  @override
  final Iterable<Type> types = const [Member, _$Member];

  @override
  final String wireName = r'Member';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Member object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'member_type';
    yield serializers.serialize(
      object.memberType,
      specifiedType: const FullType(MemberMemberTypeEnum),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(MemberStatusEnum),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Member object, {
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
    required MemberBuilder result,
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
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'member_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberMemberTypeEnum),
          ) as MemberMemberTypeEnum;
          result.memberType = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemberStatusEnum),
          ) as MemberStatusEnum;
          result.status = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Member deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemberBuilder();
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

class MemberMemberTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'REGISTERED')
  static const MemberMemberTypeEnum REGISTERED =
      _$memberMemberTypeEnum_REGISTERED;
  @BuiltValueEnumConst(wireName: r'PLACEHOLDER')
  static const MemberMemberTypeEnum PLACEHOLDER =
      _$memberMemberTypeEnum_PLACEHOLDER;

  static Serializer<MemberMemberTypeEnum> get serializer =>
      _$memberMemberTypeEnumSerializer;

  const MemberMemberTypeEnum._(String name) : super(name);

  static BuiltSet<MemberMemberTypeEnum> get values =>
      _$memberMemberTypeEnumValues;
  static MemberMemberTypeEnum valueOf(String name) =>
      _$memberMemberTypeEnumValueOf(name);
}

class MemberStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const MemberStatusEnum ACTIVE = _$memberStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'LEFT')
  static const MemberStatusEnum LEFT = _$memberStatusEnum_LEFT;
  @BuiltValueEnumConst(wireName: r'REMOVED')
  static const MemberStatusEnum REMOVED = _$memberStatusEnum_REMOVED;

  static Serializer<MemberStatusEnum> get serializer =>
      _$memberStatusEnumSerializer;

  const MemberStatusEnum._(String name) : super(name);

  static BuiltSet<MemberStatusEnum> get values => _$memberStatusEnumValues;
  static MemberStatusEnum valueOf(String name) =>
      _$memberStatusEnumValueOf(name);
}
