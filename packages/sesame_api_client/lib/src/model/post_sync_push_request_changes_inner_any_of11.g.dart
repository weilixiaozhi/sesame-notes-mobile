// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of11.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnum_fitnessTemplate =
    const PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum._(
        'fitnessTemplate');

PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'fitnessTemplate':
      return _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnum_fitnessTemplate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnum_fitnessTemplate,
]);

const PostSyncPushRequestChangesInnerAnyOf11ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf11ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf11ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf11ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf11ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf11ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf11ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf11ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf11ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf11ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf11ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf11ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf11ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessTemplate': 'fitness_template',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_template': 'fitnessTemplate',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf11ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf11ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf11ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf11ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf11ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf11ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf11ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf11
    extends PostSyncPushRequestChangesInnerAnyOf11 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf11(
          [void Function(PostSyncPushRequestChangesInnerAnyOf11Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf11Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf11._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf11 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf11Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf11Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf11Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf11 &&
        anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf11')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf11Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf11,
            PostSyncPushRequestChangesInnerAnyOf11Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf11? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf11Builder() {
    PostSyncPushRequestChangesInnerAnyOf11._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf11Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf11 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf11;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf11Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf11 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf11._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf11', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
