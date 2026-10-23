// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of9_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_normal =
    const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum._('normal');
const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_credentials =
    const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum._(
        'credentials');

PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'normal':
      return _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_normal;
    case 'credentials':
      return _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_credentials;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_normal,
  _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_credentials,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'normal': 'normal',
    'credentials': 'credentials',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'normal': 'normal',
    'credentials': 'credentials',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload {
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool? restore;
  @override
  final String? expectedFullCursor;
  @override
  final PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum type;

  factory _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload._(
      {required this.name,
      required this.createdAt,
      required this.updatedAt,
      this.restore,
      this.expectedFullCursor,
      required this.type})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload &&
        name == other.name &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        restore == other.restore &&
        expectedFullCursor == other.expectedFullCursor &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, restore.hashCode);
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('restore', restore)
          ..add('expectedFullCursor', expectedFullCursor)
          ..add('type', type))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  bool? _restore;
  bool? get restore => _$this._restore;
  set restore(bool? restore) => _$this._restore = restore;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum? _type;
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum? get type =>
      _$this._type;
  set type(PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum? type) =>
      _$this._type = type;

  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _restore = $v.restore;
      _expectedFullCursor = $v.expectedFullCursor;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt,
              r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload',
              'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt,
              r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload',
              'updatedAt'),
          restore: restore,
          expectedFullCursor: expectedFullCursor,
          type: BuiltValueNullFieldError.checkNotNull(type,
              r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload', 'type'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
