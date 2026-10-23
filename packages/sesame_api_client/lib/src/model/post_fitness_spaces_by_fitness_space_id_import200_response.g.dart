// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_import200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostFitnessSpacesByFitnessSpaceIdImport200Response
    extends PostFitnessSpacesByFitnessSpaceIdImport200Response {
  @override
  final int imported;
  @override
  final int skipped;
  @override
  final BuiltMap<String, String> ids;
  @override
  final bool replayed;

  factory _$PostFitnessSpacesByFitnessSpaceIdImport200Response(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdImport200Response._(
      {required this.imported,
      required this.skipped,
      required this.ids,
      required this.replayed})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdImport200Response rebuild(
          void Function(
                  PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder toBuilder() =>
      PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostFitnessSpacesByFitnessSpaceIdImport200Response &&
        imported == other.imported &&
        skipped == other.skipped &&
        ids == other.ids &&
        replayed == other.replayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, imported.hashCode);
    _$hash = $jc(_$hash, skipped.hashCode);
    _$hash = $jc(_$hash, ids.hashCode);
    _$hash = $jc(_$hash, replayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdImport200Response')
          ..add('imported', imported)
          ..add('skipped', skipped)
          ..add('ids', ids)
          ..add('replayed', replayed))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder
    implements
        Builder<PostFitnessSpacesByFitnessSpaceIdImport200Response,
            PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdImport200Response? _$v;

  int? _imported;
  int? get imported => _$this._imported;
  set imported(int? imported) => _$this._imported = imported;

  int? _skipped;
  int? get skipped => _$this._skipped;
  set skipped(int? skipped) => _$this._skipped = skipped;

  MapBuilder<String, String>? _ids;
  MapBuilder<String, String> get ids =>
      _$this._ids ??= MapBuilder<String, String>();
  set ids(MapBuilder<String, String>? ids) => _$this._ids = ids;

  bool? _replayed;
  bool? get replayed => _$this._replayed;
  set replayed(bool? replayed) => _$this._replayed = replayed;

  PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder() {
    PostFitnessSpacesByFitnessSpaceIdImport200Response._defaults(this);
  }

  PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _imported = $v.imported;
      _skipped = $v.skipped;
      _ids = $v.ids.toBuilder();
      _replayed = $v.replayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostFitnessSpacesByFitnessSpaceIdImport200Response other) {
    _$v = other as _$PostFitnessSpacesByFitnessSpaceIdImport200Response;
  }

  @override
  void update(
      void Function(PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdImport200Response build() => _build();

  _$PostFitnessSpacesByFitnessSpaceIdImport200Response _build() {
    _$PostFitnessSpacesByFitnessSpaceIdImport200Response _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdImport200Response._(
            imported: BuiltValueNullFieldError.checkNotNull(
                imported,
                r'PostFitnessSpacesByFitnessSpaceIdImport200Response',
                'imported'),
            skipped: BuiltValueNullFieldError.checkNotNull(
                skipped,
                r'PostFitnessSpacesByFitnessSpaceIdImport200Response',
                'skipped'),
            ids: ids.build(),
            replayed: BuiltValueNullFieldError.checkNotNull(
                replayed,
                r'PostFitnessSpacesByFitnessSpaceIdImport200Response',
                'replayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ids';
        ids.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdImport200Response',
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
