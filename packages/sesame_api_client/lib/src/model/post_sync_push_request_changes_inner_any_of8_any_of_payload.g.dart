// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of8_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_ACTIVE =
    const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum._(
        'ACTIVE');
const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_LEFT =
    const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum._(
        'LEFT');
const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_REMOVED =
    const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum._(
        'REMOVED');

PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'ACTIVE':
      return _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_ACTIVE;
    case 'LEFT':
      return _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_LEFT;
    case 'REMOVED':
      return _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_REMOVED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>(const <PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>[
  _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_ACTIVE,
  _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_LEFT,
  _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_REMOVED,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload {
  @override
  final String displayName;
  @override
  final PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?
      initialStatus;

  factory _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload._(
      {required this.displayName, this.initialStatus})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload &&
        displayName == other.displayName &&
        initialStatus == other.initialStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, initialStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload')
          ..add('displayName', displayName)
          ..add('initialStatus', initialStatus))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?
      _initialStatus;
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?
      get initialStatus => _$this._initialStatus;
  set initialStatus(
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?
              initialStatus) =>
      _$this._initialStatus = initialStatus;

  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _initialStatus = $v.initialStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload._(
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName,
              r'PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload',
              'displayName'),
          initialStatus: initialStatus,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
