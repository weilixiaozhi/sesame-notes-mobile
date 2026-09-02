// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of2_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum._(
        'expense');
const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_income =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum._('income');
const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_transfer =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum._(
        'transfer');

PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_expense;
    case 'income':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_income;
    case 'transfer':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>(const <PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_expense,
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_income,
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_transfer,
]);

const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n1 =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum._('n1');
const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n2 =
    const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum._('n2');

PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumValueOf(
        String name) {
  switch (name) {
    case 'n1':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n1;
    case 'n2':
      return _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>(const <PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>[
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n1,
  _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n2,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>
    _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload {
  @override
  final String name;
  @override
  final PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum kind;
  @override
  final PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum level;
  @override
  final int sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._(
      {required this.name,
      required this.kind,
      required this.level,
      required this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload &&
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
            r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload')
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum? _kind;
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum? get kind =>
      _$this._kind;
  set kind(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum? kind) =>
      _$this._kind = kind;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum? _level;
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum? get level =>
      _$this._level;
  set level(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum? level) =>
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

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(kind,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload', 'kind'),
          level: BuiltValueNullFieldError.checkNotNull(level,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload', 'level'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload',
              'sortOrder'),
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
