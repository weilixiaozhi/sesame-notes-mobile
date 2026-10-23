// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_import_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostFitnessSpacesByFitnessSpaceIdImportRequest
    extends PostFitnessSpacesByFitnessSpaceIdImportRequest {
  @override
  final String syncId;
  @override
  final String exportId;
  @override
  final bool? replacePreferences;
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      records;

  factory _$PostFitnessSpacesByFitnessSpaceIdImportRequest(
          [void Function(PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder()..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdImportRequest._(
      {required this.syncId,
      required this.exportId,
      this.replacePreferences,
      required this.records})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdImportRequest rebuild(
          void Function(PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder toBuilder() =>
      PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostFitnessSpacesByFitnessSpaceIdImportRequest &&
        syncId == other.syncId &&
        exportId == other.exportId &&
        replacePreferences == other.replacePreferences &&
        records == other.records;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, exportId.hashCode);
    _$hash = $jc(_$hash, replacePreferences.hashCode);
    _$hash = $jc(_$hash, records.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdImportRequest')
          ..add('syncId', syncId)
          ..add('exportId', exportId)
          ..add('replacePreferences', replacePreferences)
          ..add('records', records))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder
    implements
        Builder<PostFitnessSpacesByFitnessSpaceIdImportRequest,
            PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdImportRequest? _$v;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  String? _exportId;
  String? get exportId => _$this._exportId;
  set exportId(String? exportId) => _$this._exportId = exportId;

  bool? _replacePreferences;
  bool? get replacePreferences => _$this._replacePreferences;
  set replacePreferences(bool? replacePreferences) =>
      _$this._replacePreferences = replacePreferences;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>?
      _records;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      get records => _$this._records ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>();
  set records(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>?
              records) =>
      _$this._records = records;

  PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder() {
    PostFitnessSpacesByFitnessSpaceIdImportRequest._defaults(this);
  }

  PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _syncId = $v.syncId;
      _exportId = $v.exportId;
      _replacePreferences = $v.replacePreferences;
      _records = $v.records.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostFitnessSpacesByFitnessSpaceIdImportRequest other) {
    _$v = other as _$PostFitnessSpacesByFitnessSpaceIdImportRequest;
  }

  @override
  void update(
      void Function(PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdImportRequest build() => _build();

  _$PostFitnessSpacesByFitnessSpaceIdImportRequest _build() {
    _$PostFitnessSpacesByFitnessSpaceIdImportRequest _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdImportRequest._(
            syncId: BuiltValueNullFieldError.checkNotNull(syncId,
                r'PostFitnessSpacesByFitnessSpaceIdImportRequest', 'syncId'),
            exportId: BuiltValueNullFieldError.checkNotNull(exportId,
                r'PostFitnessSpacesByFitnessSpaceIdImportRequest', 'exportId'),
            replacePreferences: replacePreferences,
            records: records.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'records';
        records.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdImportRequest',
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
