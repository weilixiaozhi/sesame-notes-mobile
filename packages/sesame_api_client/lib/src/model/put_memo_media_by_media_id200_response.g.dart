// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_memo_media_by_media_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutMemoMediaByMediaId200Response
    extends PutMemoMediaByMediaId200Response {
  @override
  final String id;
  @override
  final int byteSize;
  @override
  final int width;
  @override
  final int height;
  @override
  final String sha256;

  factory _$PutMemoMediaByMediaId200Response(
          [void Function(PutMemoMediaByMediaId200ResponseBuilder)? updates]) =>
      (PutMemoMediaByMediaId200ResponseBuilder()..update(updates))._build();

  _$PutMemoMediaByMediaId200Response._(
      {required this.id,
      required this.byteSize,
      required this.width,
      required this.height,
      required this.sha256})
      : super._();
  @override
  PutMemoMediaByMediaId200Response rebuild(
          void Function(PutMemoMediaByMediaId200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutMemoMediaByMediaId200ResponseBuilder toBuilder() =>
      PutMemoMediaByMediaId200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutMemoMediaByMediaId200Response &&
        id == other.id &&
        byteSize == other.byteSize &&
        width == other.width &&
        height == other.height &&
        sha256 == other.sha256;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, byteSize.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, sha256.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutMemoMediaByMediaId200Response')
          ..add('id', id)
          ..add('byteSize', byteSize)
          ..add('width', width)
          ..add('height', height)
          ..add('sha256', sha256))
        .toString();
  }
}

class PutMemoMediaByMediaId200ResponseBuilder
    implements
        Builder<PutMemoMediaByMediaId200Response,
            PutMemoMediaByMediaId200ResponseBuilder> {
  _$PutMemoMediaByMediaId200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _byteSize;
  int? get byteSize => _$this._byteSize;
  set byteSize(int? byteSize) => _$this._byteSize = byteSize;

  int? _width;
  int? get width => _$this._width;
  set width(int? width) => _$this._width = width;

  int? _height;
  int? get height => _$this._height;
  set height(int? height) => _$this._height = height;

  String? _sha256;
  String? get sha256 => _$this._sha256;
  set sha256(String? sha256) => _$this._sha256 = sha256;

  PutMemoMediaByMediaId200ResponseBuilder() {
    PutMemoMediaByMediaId200Response._defaults(this);
  }

  PutMemoMediaByMediaId200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _byteSize = $v.byteSize;
      _width = $v.width;
      _height = $v.height;
      _sha256 = $v.sha256;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutMemoMediaByMediaId200Response other) {
    _$v = other as _$PutMemoMediaByMediaId200Response;
  }

  @override
  void update(void Function(PutMemoMediaByMediaId200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutMemoMediaByMediaId200Response build() => _build();

  _$PutMemoMediaByMediaId200Response _build() {
    final _$result = _$v ??
        _$PutMemoMediaByMediaId200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PutMemoMediaByMediaId200Response', 'id'),
          byteSize: BuiltValueNullFieldError.checkNotNull(
              byteSize, r'PutMemoMediaByMediaId200Response', 'byteSize'),
          width: BuiltValueNullFieldError.checkNotNull(
              width, r'PutMemoMediaByMediaId200Response', 'width'),
          height: BuiltValueNullFieldError.checkNotNull(
              height, r'PutMemoMediaByMediaId200Response', 'height'),
          sha256: BuiltValueNullFieldError.checkNotNull(
              sha256, r'PutMemoMediaByMediaId200Response', 'sha256'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
