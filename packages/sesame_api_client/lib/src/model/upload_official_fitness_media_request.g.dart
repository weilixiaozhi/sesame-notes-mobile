// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_official_fitness_media_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UploadOfficialFitnessMediaRequest
    extends UploadOfficialFitnessMediaRequest {
  @override
  final String filename;
  @override
  final String dataBase64;

  factory _$UploadOfficialFitnessMediaRequest(
          [void Function(UploadOfficialFitnessMediaRequestBuilder)? updates]) =>
      (UploadOfficialFitnessMediaRequestBuilder()..update(updates))._build();

  _$UploadOfficialFitnessMediaRequest._(
      {required this.filename, required this.dataBase64})
      : super._();
  @override
  UploadOfficialFitnessMediaRequest rebuild(
          void Function(UploadOfficialFitnessMediaRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadOfficialFitnessMediaRequestBuilder toBuilder() =>
      UploadOfficialFitnessMediaRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadOfficialFitnessMediaRequest &&
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
    return (newBuiltValueToStringHelper(r'UploadOfficialFitnessMediaRequest')
          ..add('filename', filename)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class UploadOfficialFitnessMediaRequestBuilder
    implements
        Builder<UploadOfficialFitnessMediaRequest,
            UploadOfficialFitnessMediaRequestBuilder> {
  _$UploadOfficialFitnessMediaRequest? _$v;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  UploadOfficialFitnessMediaRequestBuilder() {
    UploadOfficialFitnessMediaRequest._defaults(this);
  }

  UploadOfficialFitnessMediaRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filename = $v.filename;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadOfficialFitnessMediaRequest other) {
    _$v = other as _$UploadOfficialFitnessMediaRequest;
  }

  @override
  void update(
      void Function(UploadOfficialFitnessMediaRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadOfficialFitnessMediaRequest build() => _build();

  _$UploadOfficialFitnessMediaRequest _build() {
    final _$result = _$v ??
        _$UploadOfficialFitnessMediaRequest._(
          filename: BuiltValueNullFieldError.checkNotNull(
              filename, r'UploadOfficialFitnessMediaRequest', 'filename'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'UploadOfficialFitnessMediaRequest', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
