// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of5_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum._(
        'expense');

PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>(const <PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum_expense,
]);

const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n1 =
    const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum._('n1');
const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n2 =
    const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum._('n2');

PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumValueOf(
        String name) {
  switch (name) {
    case 'n1':
      return _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n1;
    case 'n2':
      return _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>(const <PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>[
  _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n1,
  _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n2,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>
    _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload {
  @override
  final String? baseToken;
  @override
  final String name;
  @override
  final PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum kind;
  @override
  final PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum level;
  @override
  final int sortOrder;
  @override
  final String? icon;
  @override
  final String? parentId;

  factory _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload._(
      {this.baseToken,
      required this.name,
      required this.kind,
      required this.level,
      required this.sortOrder,
      this.icon,
      this.parentId})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload &&
        baseToken == other.baseToken &&
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
    _$hash = $jc(_$hash, baseToken.hashCode);
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
            r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload')
          ..add('baseToken', baseToken)
          ..add('name', name)
          ..add('kind', kind)
          ..add('level', level)
          ..add('sortOrder', sortOrder)
          ..add('icon', icon)
          ..add('parentId', parentId))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload? _$v;

  String? _baseToken;
  String? get baseToken => _$this._baseToken;
  set baseToken(String? baseToken) => _$this._baseToken = baseToken;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum? _kind;
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum? get kind =>
      _$this._kind;
  set kind(PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum? kind) =>
      _$this._kind = kind;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum? _level;
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum? get level =>
      _$this._level;
  set level(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum? level) =>
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

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _baseToken = $v.baseToken;
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
  void replace(PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload._(
          baseToken: baseToken,
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(kind,
              r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload', 'kind'),
          level: BuiltValueNullFieldError.checkNotNull(level,
              r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload', 'level'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload',
              'sortOrder'),
          icon: icon,
          parentId: parentId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
