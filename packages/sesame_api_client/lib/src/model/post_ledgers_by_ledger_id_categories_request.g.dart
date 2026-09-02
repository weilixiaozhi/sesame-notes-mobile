// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdCategoriesRequestKindEnum
    _$postLedgersByLedgerIdCategoriesRequestKindEnum_expense =
    const PostLedgersByLedgerIdCategoriesRequestKindEnum._('expense');
const PostLedgersByLedgerIdCategoriesRequestKindEnum
    _$postLedgersByLedgerIdCategoriesRequestKindEnum_income =
    const PostLedgersByLedgerIdCategoriesRequestKindEnum._('income');
const PostLedgersByLedgerIdCategoriesRequestKindEnum
    _$postLedgersByLedgerIdCategoriesRequestKindEnum_transfer =
    const PostLedgersByLedgerIdCategoriesRequestKindEnum._('transfer');

PostLedgersByLedgerIdCategoriesRequestKindEnum
    _$postLedgersByLedgerIdCategoriesRequestKindEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$postLedgersByLedgerIdCategoriesRequestKindEnum_expense;
    case 'income':
      return _$postLedgersByLedgerIdCategoriesRequestKindEnum_income;
    case 'transfer':
      return _$postLedgersByLedgerIdCategoriesRequestKindEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdCategoriesRequestKindEnum>
    _$postLedgersByLedgerIdCategoriesRequestKindEnumValues = BuiltSet<
        PostLedgersByLedgerIdCategoriesRequestKindEnum>(const <PostLedgersByLedgerIdCategoriesRequestKindEnum>[
  _$postLedgersByLedgerIdCategoriesRequestKindEnum_expense,
  _$postLedgersByLedgerIdCategoriesRequestKindEnum_income,
  _$postLedgersByLedgerIdCategoriesRequestKindEnum_transfer,
]);

const PostLedgersByLedgerIdCategoriesRequestLevelEnum
    _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n1 =
    const PostLedgersByLedgerIdCategoriesRequestLevelEnum._('n1');
const PostLedgersByLedgerIdCategoriesRequestLevelEnum
    _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n2 =
    const PostLedgersByLedgerIdCategoriesRequestLevelEnum._('n2');

PostLedgersByLedgerIdCategoriesRequestLevelEnum
    _$postLedgersByLedgerIdCategoriesRequestLevelEnumValueOf(String name) {
  switch (name) {
    case 'n1':
      return _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n1;
    case 'n2':
      return _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdCategoriesRequestLevelEnum>
    _$postLedgersByLedgerIdCategoriesRequestLevelEnumValues = BuiltSet<
        PostLedgersByLedgerIdCategoriesRequestLevelEnum>(const <PostLedgersByLedgerIdCategoriesRequestLevelEnum>[
  _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n1,
  _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n2,
]);

Serializer<PostLedgersByLedgerIdCategoriesRequestKindEnum>
    _$postLedgersByLedgerIdCategoriesRequestKindEnumSerializer =
    _$PostLedgersByLedgerIdCategoriesRequestKindEnumSerializer();
Serializer<PostLedgersByLedgerIdCategoriesRequestLevelEnum>
    _$postLedgersByLedgerIdCategoriesRequestLevelEnumSerializer =
    _$PostLedgersByLedgerIdCategoriesRequestLevelEnumSerializer();

class _$PostLedgersByLedgerIdCategoriesRequestKindEnumSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesRequestKindEnum> {
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
    PostLedgersByLedgerIdCategoriesRequestKindEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdCategoriesRequestKindEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdCategoriesRequestKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdCategoriesRequestKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdCategoriesRequestKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdCategoriesRequestLevelEnumSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesRequestLevelEnum> {
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
    PostLedgersByLedgerIdCategoriesRequestLevelEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdCategoriesRequestLevelEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdCategoriesRequestLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdCategoriesRequestLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdCategoriesRequestLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdCategoriesRequest
    extends PostLedgersByLedgerIdCategoriesRequest {
  @override
  final String? id;
  @override
  final String name;
  @override
  final PostLedgersByLedgerIdCategoriesRequestKindEnum kind;
  @override
  final PostLedgersByLedgerIdCategoriesRequestLevelEnum level;
  @override
  final int? sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$PostLedgersByLedgerIdCategoriesRequest(
          [void Function(PostLedgersByLedgerIdCategoriesRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesRequest._(
      {this.id,
      required this.name,
      required this.kind,
      required this.level,
      this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesRequest rebuild(
          void Function(PostLedgersByLedgerIdCategoriesRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesRequest &&
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
            r'PostLedgersByLedgerIdCategoriesRequest')
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

class PostLedgersByLedgerIdCategoriesRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesRequest,
            PostLedgersByLedgerIdCategoriesRequestBuilder> {
  _$PostLedgersByLedgerIdCategoriesRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PostLedgersByLedgerIdCategoriesRequestKindEnum? _kind;
  PostLedgersByLedgerIdCategoriesRequestKindEnum? get kind => _$this._kind;
  set kind(PostLedgersByLedgerIdCategoriesRequestKindEnum? kind) =>
      _$this._kind = kind;

  PostLedgersByLedgerIdCategoriesRequestLevelEnum? _level;
  PostLedgersByLedgerIdCategoriesRequestLevelEnum? get level => _$this._level;
  set level(PostLedgersByLedgerIdCategoriesRequestLevelEnum? level) =>
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

  PostLedgersByLedgerIdCategoriesRequestBuilder() {
    PostLedgersByLedgerIdCategoriesRequest._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesRequestBuilder get _$this {
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
  void replace(PostLedgersByLedgerIdCategoriesRequest other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesRequest build() => _build();

  _$PostLedgersByLedgerIdCategoriesRequest _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdCategoriesRequest._(
          id: id,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostLedgersByLedgerIdCategoriesRequest', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'PostLedgersByLedgerIdCategoriesRequest', 'kind'),
          level: BuiltValueNullFieldError.checkNotNull(
              level, r'PostLedgersByLedgerIdCategoriesRequest', 'level'),
          sortOrder: sortOrder,
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
