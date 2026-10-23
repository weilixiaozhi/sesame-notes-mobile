// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_add_batch_request_any_of_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum_expense =
    const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
        ._('expense');

PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumValues =
    BuiltSet<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>(const <PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>[
  _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum_expense,
]);

const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n1 =
    const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
        ._('n1');
const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n2 =
    const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
        ._('n2');

PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumValueOf(
        String name) {
  switch (name) {
    case 'n1':
      return _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n1;
    case 'n2':
      return _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumValues =
    BuiltSet<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>(const <PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>[
  _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n1,
  _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n2,
]);

Serializer<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumSerializer =
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumSerializer();
Serializer<
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>
    _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumSerializer =
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumSerializer();

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
  ];
  @override
  final String wireName =
      'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
      deserialize(
              Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum> {
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
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
  ];
  @override
  final String wireName =
      'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner
    extends PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner {
  @override
  final String? id;
  @override
  final String name;
  @override
  final PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
      kind;
  @override
  final PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      level;
  @override
  final int? sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner(
          [void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner._(
      {this.id,
      required this.name,
      required this.kind,
      required this.level,
      this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
      toBuilder() =>
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner &&
        id == other.id &&
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
    _$hash = $jc(_$hash, id.hashCode);
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
            r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner,
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder> {
  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum? _kind;
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum?
      get kind => _$this._kind;
  set kind(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum?
              kind) =>
      _$this._kind = kind;

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum?
      _level;
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum?
      get level => _$this._level;
  set level(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum?
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

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder() {
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner._defaults(
        this);
  }

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
  void replace(
      PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner other) {
    _$v = other
        as _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner build() =>
      _build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner._(
          id: id,
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner',
              'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner',
              'kind'),
          level: BuiltValueNullFieldError.checkNotNull(
              level,
              r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner',
              'level'),
          sortOrder: sortOrder,
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
