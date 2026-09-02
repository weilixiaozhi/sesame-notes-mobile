// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_ledgers_by_ledger_id_categories_by_category_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_expense =
    const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum._(
        'expense');
const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_income =
    const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum._(
        'income');
const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_transfer =
    const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum._(
        'transfer');

PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_expense;
    case 'income':
      return _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_income;
    case 'transfer':
      return _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumValues =
    BuiltSet<
        PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>(const <PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>[
  _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_expense,
  _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_income,
  _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum_transfer,
]);

const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n1 =
    const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum._('n1');
const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n2 =
    const PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum._('n2');

PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumValueOf(
        String name) {
  switch (name) {
    case 'n1':
      return _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n1;
    case 'n2':
      return _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumValues =
    BuiltSet<
        PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>(const <PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>[
  _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n1,
  _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum_n2,
]);

Serializer<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum>
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumSerializer =
    _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumSerializer();
Serializer<PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum>
    _$patchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumSerializer =
    _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumSerializer();

class _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnumSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
    'income': 'income',
    'transfer': 'transfer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
    'income': 'income',
    'transfer': 'transfer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum
  ];
  @override
  final String wireName =
      'PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum';

  @override
  Object serialize(Serializers serializers,
          PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnumSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
    'n2': '2',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
    '2': 'n2',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
  ];
  @override
  final String wireName =
      'PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum';

  @override
  Object serialize(Serializers serializers,
          PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest
    extends PatchLedgersByLedgerIdCategoriesByCategoryIdRequest {
  @override
  final String? name;
  @override
  final PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum? kind;
  @override
  final PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum? level;
  @override
  final int? sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest(
          [void Function(
                  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder)?
              updates]) =>
      (PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder()
            ..update(updates))
          ._build();

  _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest._(
      {this.name,
      this.kind,
      this.level,
      this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequest rebuild(
          void Function(
                  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder toBuilder() =>
      PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchLedgersByLedgerIdCategoriesByCategoryIdRequest &&
        name == other.name &&
        kind == other.kind &&
        level == other.level &&
        sortOrder == other.sortOrder &&
        icon == other.icon &&
        parentId == other.parentId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, icon.hashCode);
    _$hash = $jc(_$hash, parentId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PatchLedgersByLedgerIdCategoriesByCategoryIdRequest')
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId))
        .toString();
  }
}

class PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder
    implements
        Builder<PatchLedgersByLedgerIdCategoriesByCategoryIdRequest,
            PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder> {
  _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum? _kind;
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum? get kind =>
      _$this._kind;
  set kind(PatchLedgersByLedgerIdCategoriesByCategoryIdRequestKindEnum? kind) =>
      _$this._kind = kind;

  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum? _level;
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum? get level =>
      _$this._level;
  set level(
          PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum?
              level) =>
      _$this._level = level;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  String? _parentId;
  String? get parentId => _$this._parentId;
  set parentId(String? parentId) => _$this._parentId = parentId;

  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder() {
    PatchLedgersByLedgerIdCategoriesByCategoryIdRequest._defaults(this);
  }

  PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _kind = $v.kind;
      _level = $v.level;
      _sortOrder = $v.sortOrder;
      _icon = $v.icon;
      _parentId = $v.parentId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchLedgersByLedgerIdCategoriesByCategoryIdRequest other) {
    _$v = other as _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest;
  }

  @override
  void update(
      void Function(PatchLedgersByLedgerIdCategoriesByCategoryIdRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchLedgersByLedgerIdCategoriesByCategoryIdRequest build() => _build();

  _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest _build() {
    final _$result = _$v ??
        _$PatchLedgersByLedgerIdCategoriesByCategoryIdRequest._(
          name: name,
          kind: kind,
          level: level,
          sortOrder: sortOrder,
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
