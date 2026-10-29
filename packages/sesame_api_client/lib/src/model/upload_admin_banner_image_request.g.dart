// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_admin_banner_image_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UploadAdminBannerImageRequest extends UploadAdminBannerImageRequest {
  @override
  final String filename;
  @override
  final String dataBase64;

  factory _$UploadAdminBannerImageRequest(
          [void Function(UploadAdminBannerImageRequestBuilder)? updates]) =>
      (UploadAdminBannerImageRequestBuilder()..update(updates))._build();

  _$UploadAdminBannerImageRequest._(
      {required this.filename, required this.dataBase64})
      : super._();
  @override
  UploadAdminBannerImageRequest rebuild(
          void Function(UploadAdminBannerImageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadAdminBannerImageRequestBuilder toBuilder() =>
      UploadAdminBannerImageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadAdminBannerImageRequest &&
        filename == other.filename &&
        dataBase64 == other.dataBase64;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UploadAdminBannerImageRequest')
          ..add('filename', filename)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class UploadAdminBannerImageRequestBuilder
    implements
        Builder<UploadAdminBannerImageRequest,
            UploadAdminBannerImageRequestBuilder> {
  _$UploadAdminBannerImageRequest? _$v;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  UploadAdminBannerImageRequestBuilder() {
    UploadAdminBannerImageRequest._defaults(this);
  }

  UploadAdminBannerImageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filename = $v.filename;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadAdminBannerImageRequest other) {
    _$v = other as _$UploadAdminBannerImageRequest;
  }

  @override
  void update(void Function(UploadAdminBannerImageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadAdminBannerImageRequest build() => _build();

  _$UploadAdminBannerImageRequest _build() {
    final _$result = _$v ??
        _$UploadAdminBannerImageRequest._(
          filename: BuiltValueNullFieldError.checkNotNull(
              filename, r'UploadAdminBannerImageRequest', 'filename'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'UploadAdminBannerImageRequest', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
