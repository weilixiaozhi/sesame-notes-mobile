// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_admin_users_by_user_id_avatar_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PutAdminUsersByUserIdAvatarRequestContentTypeEnum
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashPng =
    const PutAdminUsersByUserIdAvatarRequestContentTypeEnum._('imageSlashPng');
const PutAdminUsersByUserIdAvatarRequestContentTypeEnum
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashJpeg =
    const PutAdminUsersByUserIdAvatarRequestContentTypeEnum._('imageSlashJpeg');
const PutAdminUsersByUserIdAvatarRequestContentTypeEnum
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashWebp =
    const PutAdminUsersByUserIdAvatarRequestContentTypeEnum._('imageSlashWebp');

PutAdminUsersByUserIdAvatarRequestContentTypeEnum
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashPng':
      return _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashPng;
    case 'imageSlashJpeg':
      return _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashJpeg;
    case 'imageSlashWebp':
      return _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashWebp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PutAdminUsersByUserIdAvatarRequestContentTypeEnum>
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnumValues = BuiltSet<
        PutAdminUsersByUserIdAvatarRequestContentTypeEnum>(const <PutAdminUsersByUserIdAvatarRequestContentTypeEnum>[
  _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashPng,
  _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashJpeg,
  _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashWebp,
]);

Serializer<PutAdminUsersByUserIdAvatarRequestContentTypeEnum>
    _$putAdminUsersByUserIdAvatarRequestContentTypeEnumSerializer =
    _$PutAdminUsersByUserIdAvatarRequestContentTypeEnumSerializer();

class _$PutAdminUsersByUserIdAvatarRequestContentTypeEnumSerializer
    implements
        PrimitiveSerializer<PutAdminUsersByUserIdAvatarRequestContentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'imageSlashPng': 'image/png',
    'imageSlashJpeg': 'image/jpeg',
    'imageSlashWebp': 'image/webp',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'image/png': 'imageSlashPng',
    'image/jpeg': 'imageSlashJpeg',
    'image/webp': 'imageSlashWebp',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PutAdminUsersByUserIdAvatarRequestContentTypeEnum
  ];
  @override
  final String wireName = 'PutAdminUsersByUserIdAvatarRequestContentTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PutAdminUsersByUserIdAvatarRequestContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PutAdminUsersByUserIdAvatarRequestContentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PutAdminUsersByUserIdAvatarRequestContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PutAdminUsersByUserIdAvatarRequest
    extends PutAdminUsersByUserIdAvatarRequest {
  @override
  final PutAdminUsersByUserIdAvatarRequestContentTypeEnum contentType;
  @override
  final String dataBase64;
  @override
  final int avatarVersion;
  @override
  final String reason;

  factory _$PutAdminUsersByUserIdAvatarRequest(
          [void Function(PutAdminUsersByUserIdAvatarRequestBuilder)?
              updates]) =>
      (PutAdminUsersByUserIdAvatarRequestBuilder()..update(updates))._build();

  _$PutAdminUsersByUserIdAvatarRequest._(
      {required this.contentType,
      required this.dataBase64,
      required this.avatarVersion,
      required this.reason})
      : super._();
  @override
  PutAdminUsersByUserIdAvatarRequest rebuild(
          void Function(PutAdminUsersByUserIdAvatarRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutAdminUsersByUserIdAvatarRequestBuilder toBuilder() =>
      PutAdminUsersByUserIdAvatarRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutAdminUsersByUserIdAvatarRequest &&
        contentType == other.contentType &&
        dataBase64 == other.dataBase64 &&
        avatarVersion == other.avatarVersion &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutAdminUsersByUserIdAvatarRequest')
          ..add('contentType', contentType)
          ..add('dataBase64', dataBase64)
          ..add('avatarVersion', avatarVersion)
          ..add('reason', reason))
        .toString();
  }
}

class PutAdminUsersByUserIdAvatarRequestBuilder
    implements
        Builder<PutAdminUsersByUserIdAvatarRequest,
            PutAdminUsersByUserIdAvatarRequestBuilder> {
  _$PutAdminUsersByUserIdAvatarRequest? _$v;

  PutAdminUsersByUserIdAvatarRequestContentTypeEnum? _contentType;
  PutAdminUsersByUserIdAvatarRequestContentTypeEnum? get contentType =>
      _$this._contentType;
  set contentType(
          PutAdminUsersByUserIdAvatarRequestContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PutAdminUsersByUserIdAvatarRequestBuilder() {
    PutAdminUsersByUserIdAvatarRequest._defaults(this);
  }

  PutAdminUsersByUserIdAvatarRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _dataBase64 = $v.dataBase64;
      _avatarVersion = $v.avatarVersion;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutAdminUsersByUserIdAvatarRequest other) {
    _$v = other as _$PutAdminUsersByUserIdAvatarRequest;
  }

  @override
  void update(
      void Function(PutAdminUsersByUserIdAvatarRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutAdminUsersByUserIdAvatarRequest build() => _build();

  _$PutAdminUsersByUserIdAvatarRequest _build() {
    final _$result = _$v ??
        _$PutAdminUsersByUserIdAvatarRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(contentType,
              r'PutAdminUsersByUserIdAvatarRequest', 'contentType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'PutAdminUsersByUserIdAvatarRequest', 'dataBase64'),
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'PutAdminUsersByUserIdAvatarRequest', 'avatarVersion'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PutAdminUsersByUserIdAvatarRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
