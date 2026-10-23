// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_conflict_local_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CategoryConflictLocalPayloadKindEnum
    _$categoryConflictLocalPayloadKindEnum_expense =
    const CategoryConflictLocalPayloadKindEnum._('expense');

CategoryConflictLocalPayloadKindEnum
    _$categoryConflictLocalPayloadKindEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$categoryConflictLocalPayloadKindEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryConflictLocalPayloadKindEnum>
    _$categoryConflictLocalPayloadKindEnumValues = BuiltSet<
        CategoryConflictLocalPayloadKindEnum>(const <CategoryConflictLocalPayloadKindEnum>[
  _$categoryConflictLocalPayloadKindEnum_expense,
]);

const CategoryConflictLocalPayloadLevelEnum
    _$categoryConflictLocalPayloadLevelEnum_n1 =
    const CategoryConflictLocalPayloadLevelEnum._('n1');
const CategoryConflictLocalPayloadLevelEnum
    _$categoryConflictLocalPayloadLevelEnum_n2 =
    const CategoryConflictLocalPayloadLevelEnum._('n2');

CategoryConflictLocalPayloadLevelEnum
    _$categoryConflictLocalPayloadLevelEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$categoryConflictLocalPayloadLevelEnum_n1;
    case 'n2':
      return _$categoryConflictLocalPayloadLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryConflictLocalPayloadLevelEnum>
    _$categoryConflictLocalPayloadLevelEnumValues = BuiltSet<
        CategoryConflictLocalPayloadLevelEnum>(const <CategoryConflictLocalPayloadLevelEnum>[
  _$categoryConflictLocalPayloadLevelEnum_n1,
  _$categoryConflictLocalPayloadLevelEnum_n2,
]);

Serializer<CategoryConflictLocalPayloadKindEnum>
    _$categoryConflictLocalPayloadKindEnumSerializer =
    _$CategoryConflictLocalPayloadKindEnumSerializer();
Serializer<CategoryConflictLocalPayloadLevelEnum>
    _$categoryConflictLocalPayloadLevelEnumSerializer =
    _$CategoryConflictLocalPayloadLevelEnumSerializer();

class _$CategoryConflictLocalPayloadKindEnumSerializer
    implements PrimitiveSerializer<CategoryConflictLocalPayloadKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CategoryConflictLocalPayloadKindEnum
  ];
  @override
  final String wireName = 'CategoryConflictLocalPayloadKindEnum';

  @override
  Object serialize(
          Serializers serializers, CategoryConflictLocalPayloadKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryConflictLocalPayloadKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryConflictLocalPayloadKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryConflictLocalPayloadLevelEnumSerializer
    implements PrimitiveSerializer<CategoryConflictLocalPayloadLevelEnum> {
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
    CategoryConflictLocalPayloadLevelEnum
  ];
  @override
  final String wireName = 'CategoryConflictLocalPayloadLevelEnum';

  @override
  Object serialize(
          Serializers serializers, CategoryConflictLocalPayloadLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryConflictLocalPayloadLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryConflictLocalPayloadLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryConflictLocalPayload extends CategoryConflictLocalPayload {
  @override
  final String name;
  @override
  final CategoryConflictLocalPayloadKindEnum kind;
  @override
  final CategoryConflictLocalPayloadLevelEnum level;
  @override
  final int sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$CategoryConflictLocalPayload(
          [void Function(CategoryConflictLocalPayloadBuilder)? updates]) =>
      (CategoryConflictLocalPayloadBuilder()..update(updates))._build();

  _$CategoryConflictLocalPayload._(
      {required this.name,
      required this.kind,
      required this.level,
      required this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  CategoryConflictLocalPayload rebuild(
          void Function(CategoryConflictLocalPayloadBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryConflictLocalPayloadBuilder toBuilder() =>
      CategoryConflictLocalPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CategoryConflictLocalPayload &&
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
    return (newBuiltValueToStringHelper(r'CategoryConflictLocalPayload')
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId))
        .toString();
  }
}

class CategoryConflictLocalPayloadBuilder
    implements
        Builder<CategoryConflictLocalPayload,
            CategoryConflictLocalPayloadBuilder> {
  _$CategoryConflictLocalPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CategoryConflictLocalPayloadKindEnum? _kind;
  CategoryConflictLocalPayloadKindEnum? get kind => _$this._kind;
  set kind(CategoryConflictLocalPayloadKindEnum? kind) => _$this._kind = kind;

  CategoryConflictLocalPayloadLevelEnum? _level;
  CategoryConflictLocalPayloadLevelEnum? get level => _$this._level;
  set level(CategoryConflictLocalPayloadLevelEnum? level) =>
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

  CategoryConflictLocalPayloadBuilder() {
    CategoryConflictLocalPayload._defaults(this);
  }

  CategoryConflictLocalPayloadBuilder get _$this {
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
  void replace(CategoryConflictLocalPayload other) {
    _$v = other as _$CategoryConflictLocalPayload;
  }

  @override
  void update(void Function(CategoryConflictLocalPayloadBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CategoryConflictLocalPayload build() => _build();

  _$CategoryConflictLocalPayload _build() {
    final _$result = _$v ??
        _$CategoryConflictLocalPayload._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CategoryConflictLocalPayload', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'CategoryConflictLocalPayload', 'kind'),
          level: BuiltValueNullFieldError.checkNotNull(
              level, r'CategoryConflictLocalPayload', 'level'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'CategoryConflictLocalPayload', 'sortOrder'),
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
