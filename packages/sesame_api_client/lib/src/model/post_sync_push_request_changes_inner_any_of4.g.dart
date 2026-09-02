// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of4.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnum_exchangeRateOverride =
    const PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum._(
        'exchangeRateOverride');

PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'exchangeRateOverride':
      return _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnum_exchangeRateOverride;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnum_exchangeRateOverride,
]);

const PostSyncPushRequestChangesInnerAnyOf4ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf4ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf4ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf4ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf4ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf4ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf4ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf4ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exchangeRateOverride': 'exchange_rate_override',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exchange_rate_override': 'exchangeRateOverride',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf4ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf4ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4
    extends PostSyncPushRequestChangesInnerAnyOf4 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf4(
          [void Function(PostSyncPushRequestChangesInnerAnyOf4Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf4Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf4._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf4 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf4Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf4Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf4Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf4 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf4')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf4Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf4,
            PostSyncPushRequestChangesInnerAnyOf4Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf4? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf4Builder() {
    PostSyncPushRequestChangesInnerAnyOf4._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf4Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf4 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf4;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf4Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf4 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf4._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf4', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
