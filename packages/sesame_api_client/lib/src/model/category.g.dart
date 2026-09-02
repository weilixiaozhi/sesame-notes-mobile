// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CategoryKindEnum _$categoryKindEnum_expense =
    const CategoryKindEnum._('expense');
const CategoryKindEnum _$categoryKindEnum_income =
    const CategoryKindEnum._('income');
const CategoryKindEnum _$categoryKindEnum_transfer =
    const CategoryKindEnum._('transfer');

CategoryKindEnum _$categoryKindEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$categoryKindEnum_expense;
    case 'income':
      return _$categoryKindEnum_income;
    case 'transfer':
      return _$categoryKindEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryKindEnum> _$categoryKindEnumValues =
    BuiltSet<CategoryKindEnum>(const <CategoryKindEnum>[
  _$categoryKindEnum_expense,
  _$categoryKindEnum_income,
  _$categoryKindEnum_transfer,
]);

const CategoryLevelEnum _$categoryLevelEnum_n1 =
    const CategoryLevelEnum._('n1');
const CategoryLevelEnum _$categoryLevelEnum_n2 =
    const CategoryLevelEnum._('n2');

CategoryLevelEnum _$categoryLevelEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$categoryLevelEnum_n1;
    case 'n2':
      return _$categoryLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryLevelEnum> _$categoryLevelEnumValues =
    BuiltSet<CategoryLevelEnum>(const <CategoryLevelEnum>[
  _$categoryLevelEnum_n1,
  _$categoryLevelEnum_n2,
]);

Serializer<CategoryKindEnum> _$categoryKindEnumSerializer =
    _$CategoryKindEnumSerializer();
Serializer<CategoryLevelEnum> _$categoryLevelEnumSerializer =
    _$CategoryLevelEnumSerializer();

class _$CategoryKindEnumSerializer
    implements PrimitiveSerializer<CategoryKindEnum> {
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
  final Iterable<Type> types = const <Type>[CategoryKindEnum];
  @override
  final String wireName = 'CategoryKindEnum';

  @override
  Object serialize(Serializers serializers, CategoryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryKindEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryLevelEnumSerializer
    implements PrimitiveSerializer<CategoryLevelEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n1': '1',
    'n2': '2',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '1': 'n1',
    '2': 'n2',
  };

  @override
  final Iterable<Type> types = const <Type>[CategoryLevelEnum];
  @override
  final String wireName = 'CategoryLevelEnum';

  @override
  Object serialize(Serializers serializers, CategoryLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryLevelEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Category extends Category {
  @override
  final String id;
  @override
  final String name;
  @override
  final CategoryKindEnum kind;
  @override
  final CategoryLevelEnum level;
  @override
  final int sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;
  @override
  final DateTime updatedAt;

  factory _$Category([void Function(CategoryBuilder)? updates]) =>
      (CategoryBuilder()..update(updates))._build();

  _$Category._(
      {required this.id,
      required this.name,
      required this.kind,
      required this.level,
      required this.sortOrder,
      this.icon,
      this.parentId,
      required this.updatedAt})
      : super._();
  @override
  Category rebuild(void Function(CategoryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryBuilder toBuilder() => CategoryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Category &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        level == other.level &&
        sortOrder == other.sortOrder &&
        icon == other.icon &&
        parentId == other.parentId &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, icon.hashCode);
    _$hash = $jc(_$hash, parentId.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Category')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CategoryBuilder implements Builder<Category, CategoryBuilder> {
  _$Category? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  CategoryKindEnum? _kind;
  CategoryKindEnum? get kind => _$this._kind;
  set kind(CategoryKindEnum? kind) => _$this._kind = kind;

  CategoryLevelEnum? _level;
  CategoryLevelEnum? get level => _$this._level;
  set level(CategoryLevelEnum? level) => _$this._level = level;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  String? _parentId;
  String? get parentId => _$this._parentId;
  set parentId(String? parentId) => _$this._parentId = parentId;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CategoryBuilder() {
    Category._defaults(this);
  }

  CategoryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _level = $v.level;
      _sortOrder = $v.sortOrder;
      _icon = $v.icon;
      _parentId = $v.parentId;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Category other) {
    _$v = other as _$Category;
  }

  @override
  void update(void Function(CategoryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Category build() => _build();

  _$Category _build() {
    final _$result = _$v ??
        _$Category._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Category', 'id'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'Category', 'name'),
          kind:
              BuiltValueNullFieldError.checkNotNull(kind, r'Category', 'kind'),
          level: BuiltValueNullFieldError.checkNotNull(
              level, r'Category', 'level'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'Category', 'sortOrder'),
          icon: icon,
          parentId: parentId,
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Category', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
