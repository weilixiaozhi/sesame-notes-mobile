// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnum_transaction =
    const PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum._('transaction');

PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'transaction':
      return _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnum_transaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnum_transaction,
]);

const PostSyncPushRequestChangesInnerAnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf1ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf1ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf1ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf1ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf1ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf1ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf1ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf1ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf1ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'transaction': 'transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'transaction': 'transaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf1ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf1ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf1ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1
    extends PostSyncPushRequestChangesInnerAnyOf1 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf1(
          [void Function(PostSyncPushRequestChangesInnerAnyOf1Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf1Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf1._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf1 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf1Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf1 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf1')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf1Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf1,
            PostSyncPushRequestChangesInnerAnyOf1Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf1? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf1Builder() {
    PostSyncPushRequestChangesInnerAnyOf1._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf1 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf1;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf1 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf1._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf1', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
