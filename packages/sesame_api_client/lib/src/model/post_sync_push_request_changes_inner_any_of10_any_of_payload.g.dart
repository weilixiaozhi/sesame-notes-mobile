// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of10_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_normal =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum._(
        'normal');
const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_credentials =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum._(
        'credentials');

PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'normal':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_normal;
    case 'credentials':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_credentials;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_normal,
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_credentials,
]);

const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_deltaV1 =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum._(
        'deltaV1');
const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_fieldsV1 =
    const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum._(
        'fieldsV1');

PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumValueOf(
        String name) {
  switch (name) {
    case 'deltaV1':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_deltaV1;
    case 'fieldsV1':
      return _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_fieldsV1;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>(const <PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>[
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_deltaV1,
  _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_fieldsV1,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>
    _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'deltaV1': 'delta_v1',
    'fieldsV1': 'fields_v1',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'delta_v1': 'deltaV1',
    'fields_v1': 'fieldsV1',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload {
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum bookType;
  @override
  final String title;
  @override
  final PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum?
      bodyFormat;
  @override
  final BuiltMap<String, JsonObject?>? body;
  @override
  final String? orderKey;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload._(
      {required this.bookType,
      required this.title,
      this.bodyFormat,
      this.body,
      this.orderKey,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload &&
        bookType == other.bookType &&
        title == other.title &&
        bodyFormat == other.bodyFormat &&
        body == other.body &&
        orderKey == other.orderKey &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bookType.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, bodyFormat.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, orderKey.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload')
          ..add('bookType', bookType)
          ..add('title', title)
          ..add('bodyFormat', bodyFormat)
          ..add('body', body)
          ..add('orderKey', orderKey)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload? _$v;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum? _bookType;
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum?
      get bookType => _$this._bookType;
  set bookType(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum?
              bookType) =>
      _$this._bookType = bookType;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum? _bodyFormat;
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum?
      get bodyFormat => _$this._bodyFormat;
  set bodyFormat(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum?
              bodyFormat) =>
      _$this._bodyFormat = bodyFormat;

  MapBuilder<String, JsonObject?>? _body;
  MapBuilder<String, JsonObject?> get body =>
      _$this._body ??= MapBuilder<String, JsonObject?>();
  set body(MapBuilder<String, JsonObject?>? body) => _$this._body = body;

  String? _orderKey;
  String? get orderKey => _$this._orderKey;
  set orderKey(String? orderKey) => _$this._orderKey = orderKey;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bookType = $v.bookType;
      _title = $v.title;
      _bodyFormat = $v.bodyFormat;
      _body = $v.body?.toBuilder();
      _orderKey = $v.orderKey;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload._(
            bookType: BuiltValueNullFieldError.checkNotNull(
                bookType,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload',
                'bookType'),
            title: BuiltValueNullFieldError.checkNotNull(title,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload', 'title'),
            bodyFormat: bodyFormat,
            body: _body?.build(),
            orderKey: orderKey,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload',
                'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'body';
        _body?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
