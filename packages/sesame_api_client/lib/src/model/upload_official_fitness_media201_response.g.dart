// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_official_fitness_media201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UploadOfficialFitnessMedia201Response
    extends UploadOfficialFitnessMedia201Response {
  @override
  final String id;
  @override
  final String url;
  @override
  final int width;
  @override
  final int height;
  @override
  final int frames;
  @override
  final int byteSize;

  factory _$UploadOfficialFitnessMedia201Response(
          [void Function(UploadOfficialFitnessMedia201ResponseBuilder)?
              updates]) =>
      (UploadOfficialFitnessMedia201ResponseBuilder()..update(updates))
          ._build();

  _$UploadOfficialFitnessMedia201Response._(
      {required this.id,
      required this.url,
      required this.width,
      required this.height,
      required this.frames,
      required this.byteSize})
      : super._();
  @override
  UploadOfficialFitnessMedia201Response rebuild(
          void Function(UploadOfficialFitnessMedia201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UploadOfficialFitnessMedia201ResponseBuilder toBuilder() =>
      UploadOfficialFitnessMedia201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UploadOfficialFitnessMedia201Response &&
        id == other.id &&
        url == other.url &&
        width == other.width &&
        height == other.height &&
        frames == other.frames &&
        byteSize == other.byteSize;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, frames.hashCode);
    _$hash = $jc(_$hash, byteSize.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'UploadOfficialFitnessMedia201Response')
          ..add('id', id)
          ..add('url', url)
          ..add('width', width)
          ..add('height', height)
          ..add('frames', frames)
          ..add('byteSize', byteSize))
        .toString();
  }
}

class UploadOfficialFitnessMedia201ResponseBuilder
    implements
        Builder<UploadOfficialFitnessMedia201Response,
            UploadOfficialFitnessMedia201ResponseBuilder> {
  _$UploadOfficialFitnessMedia201Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  int? _width;
  int? get width => _$this._width;
  set width(int? width) => _$this._width = width;

  int? _height;
  int? get height => _$this._height;
  set height(int? height) => _$this._height = height;

  int? _frames;
  int? get frames => _$this._frames;
  set frames(int? frames) => _$this._frames = frames;

  int? _byteSize;
  int? get byteSize => _$this._byteSize;
  set byteSize(int? byteSize) => _$this._byteSize = byteSize;

  UploadOfficialFitnessMedia201ResponseBuilder() {
    UploadOfficialFitnessMedia201Response._defaults(this);
  }

  UploadOfficialFitnessMedia201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _url = $v.url;
      _width = $v.width;
      _height = $v.height;
      _frames = $v.frames;
      _byteSize = $v.byteSize;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UploadOfficialFitnessMedia201Response other) {
    _$v = other as _$UploadOfficialFitnessMedia201Response;
  }

  @override
  void update(
      void Function(UploadOfficialFitnessMedia201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UploadOfficialFitnessMedia201Response build() => _build();

  _$UploadOfficialFitnessMedia201Response _build() {
    final _$result = _$v ??
        _$UploadOfficialFitnessMedia201Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UploadOfficialFitnessMedia201Response', 'id'),
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'UploadOfficialFitnessMedia201Response', 'url'),
          width: BuiltValueNullFieldError.checkNotNull(
              width, r'UploadOfficialFitnessMedia201Response', 'width'),
          height: BuiltValueNullFieldError.checkNotNull(
              height, r'UploadOfficialFitnessMedia201Response', 'height'),
          frames: BuiltValueNullFieldError.checkNotNull(
              frames, r'UploadOfficialFitnessMedia201Response', 'frames'),
          byteSize: BuiltValueNullFieldError.checkNotNull(
              byteSize, r'UploadOfficialFitnessMedia201Response', 'byteSize'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
