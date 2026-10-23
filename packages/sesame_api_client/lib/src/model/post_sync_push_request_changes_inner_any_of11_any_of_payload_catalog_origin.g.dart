// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of11_any_of_payload_catalog_origin.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnum_official =
    const PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
        ._('official');

PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumValueOf(
        String name) {
  switch (name) {
    case 'official':
      return _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnum_official;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>(const <PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>[
  _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnum_official,
]);

Serializer<
        PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>
    _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_EnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_EnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'official': 'official',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'official': 'official',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin
    extends PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin {
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
      source_;
  @override
  final String itemId;
  @override
  final int revision;

  factory _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin._(
      {required this.source_, required this.itemId, required this.revision})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
      toBuilder() =>
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin &&
        source_ == other.source_ &&
        itemId == other.itemId &&
        revision == other.revision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin')
          ..add('source_', source_)
          ..add('itemId', itemId)
          ..add('revision', revision))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin,
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin? _$v;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum?
      _source_;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum?
      get source_ => _$this._source_;
  set source_(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum?
              source_) =>
      _$this._source_ = source_;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder() {
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin._defaults(
        this);
  }

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _source_ = $v.source_;
      _itemId = $v.itemId;
      _revision = $v.revision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin other) {
    _$v = other
        as _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin build() =>
      _build();

  _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin._(
          source_: BuiltValueNullFieldError.checkNotNull(
              source_,
              r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin',
              'source_'),
          itemId: BuiltValueNullFieldError.checkNotNull(
              itemId,
              r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin',
              'itemId'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin',
              'revision'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
