// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnum_ledger =
    const PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum._('ledger');

PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'ledger':
      return _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnum_ledger;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnum_ledger,
]);

const PostSyncPushRequestChangesInnerAnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOfActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOfActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOfActionEnum
    _$postSyncPushRequestChangesInnerAnyOfActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOfActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOfActionEnum>(const <PostSyncPushRequestChangesInnerAnyOfActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOfActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfEntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOfActionEnum>
    _$postSyncPushRequestChangesInnerAnyOfActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOfActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ledger': 'ledger',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ledger': 'ledger',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOfActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOfActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOfActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOfActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOfActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOfActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOfActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf
    extends PostSyncPushRequestChangesInnerAnyOf {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf(
          [void Function(PostSyncPushRequestChangesInnerAnyOfBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfBuilder()..update(updates))._build();

  _$PostSyncPushRequestChangesInnerAnyOf._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf &&
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
    return (newBuiltValueToStringHelper(r'PostSyncPushRequestChangesInnerAnyOf')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOfBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf,
            PostSyncPushRequestChangesInnerAnyOfBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOfBuilder() {
    PostSyncPushRequestChangesInnerAnyOf._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
