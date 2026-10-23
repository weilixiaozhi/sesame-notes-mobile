// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of6.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnum_recurringTransaction =
    const PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum._(
        'recurringTransaction');

PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'recurringTransaction':
      return _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnum_recurringTransaction;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnum_recurringTransaction,
]);

const PostSyncPushRequestChangesInnerAnyOf6ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf6ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf6ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf6ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf6ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf6ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf6ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf6ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf6ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf6ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'recurringTransaction': 'recurring_transaction',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'recurring_transaction': 'recurringTransaction',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf6ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf6ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf6ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6
    extends PostSyncPushRequestChangesInnerAnyOf6 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf6(
          [void Function(PostSyncPushRequestChangesInnerAnyOf6Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf6Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf6._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf6 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf6Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf6Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf6Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf6 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf6')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf6Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf6,
            PostSyncPushRequestChangesInnerAnyOf6Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf6? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf6Builder() {
    PostSyncPushRequestChangesInnerAnyOf6._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf6Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf6 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf6;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf6Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf6 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf6._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf6', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
