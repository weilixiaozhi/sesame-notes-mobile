// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of7.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnum_exchangeRateOverride =
    const PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum._(
        'exchangeRateOverride');

PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'exchangeRateOverride':
      return _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnum_exchangeRateOverride;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnum_exchangeRateOverride,
]);

const PostSyncPushRequestChangesInnerAnyOf7ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf7ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf7ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf7ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf7ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf7ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf7ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf7ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf7ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf7ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf7ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf7ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf7ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf7ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exchangeRateOverride': 'exchange_rate_override',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exchange_rate_override': 'exchangeRateOverride',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf7ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf7ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf7ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf7ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf7ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf7ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf7ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf7
    extends PostSyncPushRequestChangesInnerAnyOf7 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf7(
          [void Function(PostSyncPushRequestChangesInnerAnyOf7Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf7Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf7._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf7 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf7Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf7Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf7Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf7 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf7')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf7Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf7,
            PostSyncPushRequestChangesInnerAnyOf7Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf7? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf7Builder() {
    PostSyncPushRequestChangesInnerAnyOf7._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf7Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf7 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf7;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf7Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf7 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf7 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf7._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf7', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
