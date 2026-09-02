//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ledger.g.dart';

/// Ledger
///
/// Properties:
/// * [id]
/// * [syncId]
/// * [name]
/// * [currency]
/// * [monthStartDay]
/// * [aaEnabled]
/// * [role]
/// * [memberCount]
/// * [updatedAt]
@BuiltValue()
abstract class Ledger implements Built<Ledger, LedgerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'month_start_day')
  int get monthStartDay;

  @BuiltValueField(wireName: r'aa_enabled')
  bool get aaEnabled;

  @BuiltValueField(wireName: r'role')
  LedgerRoleEnum get role;
  // enum roleEnum {  owner,  editor,  };

  @BuiltValueField(wireName: r'member_count')
  int get memberCount;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  Ledger._();

  factory Ledger([void updates(LedgerBuilder b)]) = _$Ledger;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LedgerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Ledger> get serializer => _$LedgerSerializer();
}

class _$LedgerSerializer implements PrimitiveSerializer<Ledger> {
  @override
  final Iterable<Type> types = const [Ledger, _$Ledger];

  @override
  final String wireName = r'Ledger';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Ledger object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'month_start_day';
    yield serializers.serialize(
      object.monthStartDay,
      specifiedType: const FullType(int),
    );
    yield r'aa_enabled';
    yield serializers.serialize(
      object.aaEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(LedgerRoleEnum),
    );
    yield r'member_count';
    yield serializers.serialize(
      object.memberCount,
      specifiedType: const FullType(int),
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
    Ledger object, {
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
    required LedgerBuilder result,
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
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'month_start_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.monthStartDay = valueDes;
          break;
        case r'aa_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.aaEnabled = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LedgerRoleEnum),
          ) as LedgerRoleEnum;
          result.role = valueDes;
          break;
        case r'member_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCount = valueDes;
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
  Ledger deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LedgerBuilder();
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

class LedgerRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'owner')
  static const LedgerRoleEnum owner = _$ledgerRoleEnum_owner;
  @BuiltValueEnumConst(wireName: r'editor')
  static const LedgerRoleEnum editor = _$ledgerRoleEnum_editor;

  static Serializer<LedgerRoleEnum> get serializer =>
      _$ledgerRoleEnumSerializer;

  const LedgerRoleEnum._(String name) : super(name);

  static BuiltSet<LedgerRoleEnum> get values => _$ledgerRoleEnumValues;
  static LedgerRoleEnum valueOf(String name) => _$ledgerRoleEnumValueOf(name);
}
