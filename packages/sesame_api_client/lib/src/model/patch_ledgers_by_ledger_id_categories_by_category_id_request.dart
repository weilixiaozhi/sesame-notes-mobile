//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_ledgers_by_ledger_id_categories_by_category_id_request.g.dart';

/// PatchLedgersByLedgerIdCategoriesByCategoryIdRequest
///
/// Properties:
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
@BuiltValue()
abstract class PatchLedgersByLedgerIdCategoriesByCategoryIdRequest
    implements
        Built<PatchLedgersByLedgerIdCategoriesByCategoryIdRequest,
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'kind')
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum? get kind;
  // enum kindEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'level')
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum? get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  PatchLedgersByLedgerIdCategoriesByCategoryIdRequest._();

  factory PatchLedgersByLedgerIdCategoriesByCategoryIdRequest(
          [void updates(
              PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder b)]) =
      _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchLedgersByLedgerIdCategoriesByCategoryIdRequest>
      get serializer =>
          _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestSerializer();
}

class _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequest,
    _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest
  ];

  @override
  final String wireName =
      r'PatchLedgersByLedgerIdCategoriesByCategoryIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.kind != null) {
      yield r'kind';
      yield serializers.serialize(
        object.kind,
        specifiedType: const FullType(
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum),
      );
    }
    if (object.level != null) {
      yield r'level';
      yield serializers.serialize(
        object.level,
        specifiedType: const FullType(
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum),
      );
    }
    if (object.sortOrder != null) {
      yield r'sort_order';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(int),
      );
    }
    if (object.icon != null) {
      yield r'icon';
      yield serializers.serialize(
        object.icon,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.parentId != null) {
      yield r'parent_id';
      yield serializers.serialize(
        object.parentId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequest object, {
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
    required PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum),
          ) as PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum?;
          if (valueDes == null) continue;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum),
          ) as PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum?;
          if (valueDes == null) continue;
          result.level = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sortOrder = valueDes;
          break;
        case r'icon':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.icon = valueDes;
          break;
        case r'parent_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder();
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

class PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
      expense =
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
      income =
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
      transfer =
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_transfer;

  static Serializer<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>
      get serializer =>
          _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumSerializer;

  const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum._(
      String name)
      : super(name);

  static BuiltSet<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>
      get values =>
          _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumValues;
  static PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum valueOf(
          String name) =>
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumValueOf(
          name);
}

class PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum n1 =
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum n2 =
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n2;

  static Serializer<
          PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>
      get serializer =>
          _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumSerializer;

  const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum._(
      String name)
      : super(name);

  static BuiltSet<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>
      get values =>
          _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumValues;
  static PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum valueOf(
          String name) =>
      _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumValueOf(
          name);
}
