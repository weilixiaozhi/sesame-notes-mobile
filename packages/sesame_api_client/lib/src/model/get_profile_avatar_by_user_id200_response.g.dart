// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile_avatar_by_user_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetProfileAvatarByUserId200ResponseContentTypeEnum
    _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashPng =
    const GetProfileAvatarByUserId200ResponseContentTypeEnum._('imageSlashPng');
const GetProfileAvatarByUserId200ResponseContentTypeEnum
    _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashJpeg =
    const GetProfileAvatarByUserId200ResponseContentTypeEnum._(
        'imageSlashJpeg');
const GetProfileAvatarByUserId200ResponseContentTypeEnum
    _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashWebp =
    const GetProfileAvatarByUserId200ResponseContentTypeEnum._(
        'imageSlashWebp');

GetProfileAvatarByUserId200ResponseContentTypeEnum
    _$getProfileAvatarByUserId200ResponseContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashPng':
      return _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashPng;
    case 'imageSlashJpeg':
      return _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashJpeg;
    case 'imageSlashWebp':
      return _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashWebp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetProfileAvatarByUserId200ResponseContentTypeEnum>
    _$getProfileAvatarByUserId200ResponseContentTypeEnumValues = BuiltSet<
        GetProfileAvatarByUserId200ResponseContentTypeEnum>(const <GetProfileAvatarByUserId200ResponseContentTypeEnum>[
  _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashPng,
  _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashJpeg,
  _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashWebp,
]);

Serializer<GetProfileAvatarByUserId200ResponseContentTypeEnum>
    _$getProfileAvatarByUserId200ResponseContentTypeEnumSerializer =
    _$GetProfileAvatarByUserId200ResponseContentTypeEnumSerializer();

class _$GetProfileAvatarByUserId200ResponseContentTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetProfileAvatarByUserId200ResponseContentTypeEnum> {
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
    GetProfileAvatarByUserId200ResponseContentTypeEnum
  ];
  @override
  final String wireName = 'GetProfileAvatarByUserId200ResponseContentTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GetProfileAvatarByUserId200ResponseContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetProfileAvatarByUserId200ResponseContentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetProfileAvatarByUserId200ResponseContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetProfileAvatarByUserId200Response
    extends GetProfileAvatarByUserId200Response {
  @override
  final GetProfileAvatarByUserId200ResponseContentTypeEnum contentType;
  @override
  final String dataBase64;
  @override
  final int avatarVersion;

  factory _$GetProfileAvatarByUserId200Response(
          [void Function(GetProfileAvatarByUserId200ResponseBuilder)?
              updates]) =>
      (GetProfileAvatarByUserId200ResponseBuilder()..update(updates))._build();

  _$GetProfileAvatarByUserId200Response._(
      {required this.contentType,
      required this.dataBase64,
      required this.avatarVersion})
      : super._();
  @override
  GetProfileAvatarByUserId200Response rebuild(
          void Function(GetProfileAvatarByUserId200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetProfileAvatarByUserId200ResponseBuilder toBuilder() =>
      GetProfileAvatarByUserId200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetProfileAvatarByUserId200Response &&
        contentType == other.contentType &&
        dataBase64 == other.dataBase64 &&
        avatarVersion == other.avatarVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetProfileAvatarByUserId200Response')
          ..add('contentType', contentType)
          ..add('dataBase64', dataBase64)
          ..add('avatarVersion', avatarVersion))
        .toString();
  }
}

class GetProfileAvatarByUserId200ResponseBuilder
    implements
        Builder<GetProfileAvatarByUserId200Response,
            GetProfileAvatarByUserId200ResponseBuilder> {
  _$GetProfileAvatarByUserId200Response? _$v;

  GetProfileAvatarByUserId200ResponseContentTypeEnum? _contentType;
  GetProfileAvatarByUserId200ResponseContentTypeEnum? get contentType =>
      _$this._contentType;
  set contentType(
          GetProfileAvatarByUserId200ResponseContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  GetProfileAvatarByUserId200ResponseBuilder() {
    GetProfileAvatarByUserId200Response._defaults(this);
  }

  GetProfileAvatarByUserId200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _dataBase64 = $v.dataBase64;
      _avatarVersion = $v.avatarVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetProfileAvatarByUserId200Response other) {
    _$v = other as _$GetProfileAvatarByUserId200Response;
  }

  @override
  void update(
      void Function(GetProfileAvatarByUserId200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetProfileAvatarByUserId200Response build() => _build();

  _$GetProfileAvatarByUserId200Response _build() {
    final _$result = _$v ??
        _$GetProfileAvatarByUserId200Response._(
          contentType: BuiltValueNullFieldError.checkNotNull(contentType,
              r'GetProfileAvatarByUserId200Response', 'contentType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'GetProfileAvatarByUserId200Response', 'dataBase64'),
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'GetProfileAvatarByUserId200Response', 'avatarVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
