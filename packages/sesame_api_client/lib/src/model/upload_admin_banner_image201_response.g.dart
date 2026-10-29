// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_admin_banner_image201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UploadAdminBannerImage201Response
    extends UploadAdminBannerImage201Response {
  @override
  final String id;
  @override
  final String imagePath;
  @override
  final int width;
  @override
  final int height;

  factory _$UploadAdminBannerImage201Response(
          [void Function(UploadAdminBannerImage201ResponseBuilder)? updates]) =>
      (UploadAdminBannerImage201ResponseBuilder()..update(updates))._build();

  _$UploadAdminBannerImage201Response._(
      {required this.id,
      required this.imagePath,
      required this.width,
      required this.height})
      : super._();
  @override
  UploadAdminBannerImage201Response rebuild(
          void Function(UploadAdminBannerImage201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadAdminBannerImage201ResponseBuilder toBuilder() =>
      UploadAdminBannerImage201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadAdminBannerImage201Response &&
        id == other.id &&
        imagePath == other.imagePath &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, imagePath.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UploadAdminBannerImage201Response')
          ..add('id', id)
          ..add('imagePath', imagePath)
          ..add('width', width)
          ..add('height', height))
        .toString();
  }
}

class UploadAdminBannerImage201ResponseBuilder
    implements
        Builder<UploadAdminBannerImage201Response,
            UploadAdminBannerImage201ResponseBuilder> {
  _$UploadAdminBannerImage201Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _imagePath;
  String? get imagePath => _$this._imagePath;
  set imagePath(String? imagePath) => _$this._imagePath = imagePath;

  int? _width;
  int? get width => _$this._width;
  set width(int? width) => _$this._width = width;

  int? _height;
  int? get height => _$this._height;
  set height(int? height) => _$this._height = height;

  UploadAdminBannerImage201ResponseBuilder() {
    UploadAdminBannerImage201Response._defaults(this);
  }

  UploadAdminBannerImage201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _imagePath = $v.imagePath;
      _width = $v.width;
      _height = $v.height;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadAdminBannerImage201Response other) {
    _$v = other as _$UploadAdminBannerImage201Response;
  }

  @override
  void update(
      void Function(UploadAdminBannerImage201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadAdminBannerImage201Response build() => _build();

  _$UploadAdminBannerImage201Response _build() {
    final _$result = _$v ??
        _$UploadAdminBannerImage201Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UploadAdminBannerImage201Response', 'id'),
          imagePath: BuiltValueNullFieldError.checkNotNull(
              imagePath, r'UploadAdminBannerImage201Response', 'imagePath'),
          width: BuiltValueNullFieldError.checkNotNull(
              width, r'UploadAdminBannerImage201Response', 'width'),
          height: BuiltValueNullFieldError.checkNotNull(
              height, r'UploadAdminBannerImage201Response', 'height'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
