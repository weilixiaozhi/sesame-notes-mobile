//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_member_stats200_response_items_inner.g.dart';

/// GetLedgersByLedgerIdMemberStats200ResponseItemsInner
///
/// Properties:
/// * [userId]
/// * [memberId]
/// * [sesameNumber]
/// * [displayName]
/// * [avatarUrl]
/// * [avatarVersion]
/// * [role]
/// * [incomeTotal]
/// * [expenseTotal]
/// * [txCount]
@BuiltValue()
abstract class GetLedgersByLedgerIdMemberStats200ResponseItemsInner
    implements
        Built<GetLedgersByLedgerIdMemberStats200ResponseItemsInner,
            GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String? get userId;

  @BuiltValueField(wireName: r'member_id')
  String? get memberId;

  @BuiltValueField(wireName: r'sesame_number')
  String? get sesameNumber;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'role')
  GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum get role;
  // enum roleEnum {  owner,  editor,  removed,  unknown,  };

  @BuiltValueField(wireName: r'income_total')
  String get incomeTotal;

  @BuiltValueField(wireName: r'expense_total')
  String get expenseTotal;

  @BuiltValueField(wireName: r'tx_count')
  int get txCount;

  GetLedgersByLedgerIdMemberStats200ResponseItemsInner._();

  factory GetLedgersByLedgerIdMemberStats200ResponseItemsInner(
          [void updates(
              GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder b)]) =
      _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>
      get serializer =>
          _$GetLedgersByLedgerIdMemberStats200ResponseItemsInnerSerializer();
}

class _$GetLedgersByLedgerIdMemberStats200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdMemberStats200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdMemberStats200ResponseItemsInner,
    _$GetLedgersByLedgerIdMemberStats200ResponseItemsInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdMemberStats200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdMemberStats200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield object.userId == null
        ? null
        : serializers.serialize(
            object.userId,
            specifiedType: const FullType.nullable(String),
          );
    if (object.memberId != null) {
      yield r'member_id';
      yield serializers.serialize(
        object.memberId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
      specifiedType: const FullType(
          GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum),
    );
    yield r'income_total';
    yield serializers.serialize(
      object.incomeTotal,
      specifiedType: const FullType(String),
    );
    yield r'expense_total';
    yield serializers.serialize(
      object.expenseTotal,
      specifiedType: const FullType(String),
    );
    yield r'tx_count';
    yield serializers.serialize(
      object.txCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdMemberStats200ResponseItemsInner object, {
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
    required GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
          break;
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.memberId = valueDes;
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
                GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum),
          ) as GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum;
          result.role = valueDes;
          break;
        case r'income_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.incomeTotal = valueDes;
          break;
        case r'expense_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expenseTotal = valueDes;
          break;
        case r'tx_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.txCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdMemberStats200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdMemberStats200ResponseItemsInnerBuilder();
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

class GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'owner')
  static const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
      owner =
      _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_owner;
  @BuiltValueEnumConst(wireName: r'editor')
  static const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
      editor =
      _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_editor;
  @BuiltValueEnumConst(wireName: r'removed')
  static const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
      removed =
      _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_removed;
  @BuiltValueEnumConst(wireName: r'unknown')
  static const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum
      unknown =
      _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum_unknown;

  static Serializer<
          GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>
      get serializer =>
          _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumSerializer;

  const GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum._(
      String name)
      : super(name);

  static BuiltSet<GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum>
      get values =>
          _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumValues;
  static GetLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnum valueOf(
          String name) =>
      _$getLedgersByLedgerIdMemberStats200ResponseItemsInnerRoleEnumValueOf(
          name);
}
