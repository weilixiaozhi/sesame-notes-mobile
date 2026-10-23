// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of12.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnum_fitnessPlan =
    const PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum._('fitnessPlan');

PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPlan':
      return _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnum_fitnessPlan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnum_fitnessPlan,
]);

const PostSyncPushRequestChangesInnerAnyOf12ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf12ActionEnum_delete =
    const PostSyncPushRequestChangesInnerAnyOf12ActionEnum._('delete');

PostSyncPushRequestChangesInnerAnyOf12ActionEnum
    _$postSyncPushRequestChangesInnerAnyOf12ActionEnumValueOf(String name) {
  switch (name) {
    case 'delete':
      return _$postSyncPushRequestChangesInnerAnyOf12ActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf12ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf12ActionEnumValues = BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf12ActionEnum>(const <PostSyncPushRequestChangesInnerAnyOf12ActionEnum>[
  _$postSyncPushRequestChangesInnerAnyOf12ActionEnum_delete,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf12ActionEnum>
    _$postSyncPushRequestChangesInnerAnyOf12ActionEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf12ActionEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlan': 'fitness_plan',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_plan': 'fitnessPlan',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf12ActionEnumSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf12ActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf12ActionEnum
  ];
  @override
  final String wireName = 'PostSyncPushRequestChangesInnerAnyOf12ActionEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf12ActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf12ActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf12ActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf12
    extends PostSyncPushRequestChangesInnerAnyOf12 {
  @override
  final AnyOf anyOf;

  factory _$PostSyncPushRequestChangesInnerAnyOf12(
          [void Function(PostSyncPushRequestChangesInnerAnyOf12Builder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf12Builder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf12._({required this.anyOf}) : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf12 rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf12Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf12Builder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf12Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf12 &&
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
            r'PostSyncPushRequestChangesInnerAnyOf12')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf12Builder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf12,
            PostSyncPushRequestChangesInnerAnyOf12Builder> {
  _$PostSyncPushRequestChangesInnerAnyOf12? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostSyncPushRequestChangesInnerAnyOf12Builder() {
    PostSyncPushRequestChangesInnerAnyOf12._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf12Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf12 other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf12;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf12Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf12 build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf12 _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf12._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PostSyncPushRequestChangesInnerAnyOf12', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
