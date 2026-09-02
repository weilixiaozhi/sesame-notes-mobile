// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_profile_avatar_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PutProfileAvatarRequestContentTypeEnum
    _$putProfileAvatarRequestContentTypeEnum_imageSlashPng =
    const PutProfileAvatarRequestContentTypeEnum._('imageSlashPng');
const PutProfileAvatarRequestContentTypeEnum
    _$putProfileAvatarRequestContentTypeEnum_imageSlashJpeg =
    const PutProfileAvatarRequestContentTypeEnum._('imageSlashJpeg');
const PutProfileAvatarRequestContentTypeEnum
    _$putProfileAvatarRequestContentTypeEnum_imageSlashWebp =
    const PutProfileAvatarRequestContentTypeEnum._('imageSlashWebp');

PutProfileAvatarRequestContentTypeEnum
    _$putProfileAvatarRequestContentTypeEnumValueOf(String name) {
  switch (name) {
    case 'imageSlashPng':
      return _$putProfileAvatarRequestContentTypeEnum_imageSlashPng;
    case 'imageSlashJpeg':
      return _$putProfileAvatarRequestContentTypeEnum_imageSlashJpeg;
    case 'imageSlashWebp':
      return _$putProfileAvatarRequestContentTypeEnum_imageSlashWebp;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PutProfileAvatarRequestContentTypeEnum>
    _$putProfileAvatarRequestContentTypeEnumValues = BuiltSet<
        PutProfileAvatarRequestContentTypeEnum>(const <PutProfileAvatarRequestContentTypeEnum>[
  _$putProfileAvatarRequestContentTypeEnum_imageSlashPng,
  _$putProfileAvatarRequestContentTypeEnum_imageSlashJpeg,
  _$putProfileAvatarRequestContentTypeEnum_imageSlashWebp,
]);

Serializer<PutProfileAvatarRequestContentTypeEnum>
    _$putProfileAvatarRequestContentTypeEnumSerializer =
    _$PutProfileAvatarRequestContentTypeEnumSerializer();

class _$PutProfileAvatarRequestContentTypeEnumSerializer
    implements PrimitiveSerializer<PutProfileAvatarRequestContentTypeEnum> {
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
    PutProfileAvatarRequestContentTypeEnum
  ];
  @override
  final String wireName = 'PutProfileAvatarRequestContentTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PutProfileAvatarRequestContentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PutProfileAvatarRequestContentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PutProfileAvatarRequestContentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PutProfileAvatarRequest extends PutProfileAvatarRequest {
  @override
  final PutProfileAvatarRequestContentTypeEnum contentType;
  @override
  final String dataBase64;

  factory _$PutProfileAvatarRequest(
          [void Function(PutProfileAvatarRequestBuilder)? updates]) =>
      (PutProfileAvatarRequestBuilder()..update(updates))._build();

  _$PutProfileAvatarRequest._(
      {required this.contentType, required this.dataBase64})
      : super._();
  @override
  PutProfileAvatarRequest rebuild(
          void Function(PutProfileAvatarRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutProfileAvatarRequestBuilder toBuilder() =>
      PutProfileAvatarRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutProfileAvatarRequest &&
        contentType == other.contentType &&
        dataBase64 == other.dataBase64;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutProfileAvatarRequest')
          ..add('contentType', contentType)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class PutProfileAvatarRequestBuilder
    implements
        Builder<PutProfileAvatarRequest, PutProfileAvatarRequestBuilder> {
  _$PutProfileAvatarRequest? _$v;

  PutProfileAvatarRequestContentTypeEnum? _contentType;
  PutProfileAvatarRequestContentTypeEnum? get contentType =>
      _$this._contentType;
  set contentType(PutProfileAvatarRequestContentTypeEnum? contentType) =>
      _$this._contentType = contentType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  PutProfileAvatarRequestBuilder() {
    PutProfileAvatarRequest._defaults(this);
  }

  PutProfileAvatarRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutProfileAvatarRequest other) {
    _$v = other as _$PutProfileAvatarRequest;
  }

  @override
  void update(void Function(PutProfileAvatarRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutProfileAvatarRequest build() => _build();

  _$PutProfileAvatarRequest _build() {
    final _$result = _$v ??
        _$PutProfileAvatarRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'PutProfileAvatarRequest', 'contentType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'PutProfileAvatarRequest', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
