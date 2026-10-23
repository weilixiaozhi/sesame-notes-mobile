// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of13.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnum_fitnessWorkout =
    const PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum._(
        'fitnessWorkout');

PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'fitnessWorkout':
      return _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnum_fitnessWorkout;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnum_fitnessWorkout,
]);

const PostSyncPushRequestChangesInnerAnyOf13ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf13ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf13ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf13ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf13ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf13ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf13ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf13ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf13ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf13ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessWorkout': 'fitness_workout',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_workout': 'fitnessWorkout',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf13ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf13ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf13ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13
    extends PostSyncPushRequestChangesInnerAnyOf13 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf13(
          [void Function(PostSyncPushRequestChangesInnerAnyOf13Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf13Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf13._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf13 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf13Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf13Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf13Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf13 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf13')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf13Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf13,
            PostSyncPushRequestChangesInnerAnyOf13Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf13? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf13Builder() {
    PostSyncPushRequestChangesInnerAnyOf13._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf13Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf13 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf13;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf13Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf13 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf13._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf13', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
