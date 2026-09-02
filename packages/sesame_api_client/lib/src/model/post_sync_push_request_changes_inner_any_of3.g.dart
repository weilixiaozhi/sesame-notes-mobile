// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of3.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_recurringTransaction =
    const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum._(
        'recurringTransaction');

PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'recurringTransaction':
      return _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_recurringTransaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_recurringTransaction,
]);

const PostSyncPushRequestChangesInnerAnyOf3ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf3ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf3ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf3ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'recurringTransaction': 'recurring_transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'recurring_transaction': 'recurringTransaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf3ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3
    extends PostSyncPushRequestChangesInnerAnyOf3 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf3(
          [void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf3Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf3._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf3 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf3Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf3Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf3 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf3')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf3Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf3,
            PostSyncPushRequestChangesInnerAnyOf3Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf3? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf3Builder() {
    PostSyncPushRequestChangesInnerAnyOf3._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf3Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf3 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf3;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf3Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf3 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf3._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf3', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
