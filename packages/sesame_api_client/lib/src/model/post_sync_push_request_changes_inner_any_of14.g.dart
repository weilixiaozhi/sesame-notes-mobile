// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of14.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnum_fitnessPreferences =
    const PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum._(
        'fitnessPreferences');

PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPreferences':
      return _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnum_fitnessPreferences;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnum_fitnessPreferences,
]);

const PostSyncPushRequestChangesInnerAnyOf14ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf14ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf14ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf14ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf14ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf14ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf14ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf14ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf14ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf14ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf14ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf14ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf14ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf14ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPreferences': 'fitness_preferences',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_preferences': 'fitnessPreferences',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf14ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf14ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf14ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf14ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf14ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf14ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf14ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf14
    extends PostSyncPushRequestChangesInnerAnyOf14 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf14(
          [void Function(PostSyncPushRequestChangesInnerAnyOf14Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf14Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf14._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf14 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf14Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf14Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf14Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf14 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf14')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf14Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf14,
            PostSyncPushRequestChangesInnerAnyOf14Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf14? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf14Builder() {
    PostSyncPushRequestChangesInnerAnyOf14._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf14Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf14 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf14;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf14Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf14 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf14 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf14._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf14', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
