// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdExport200Response
    extends GetFitnessSpacesByFitnessSpaceIdExport200Response {
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      records;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200Response._({required this.records})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdExport200Response &&
        records == other.records;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, records.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdExport200Response')
          ..add('records', records))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdExport200Response,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200Response? _$v;

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

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdExport200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _records = $v.records.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdExport200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdExport200Response;
  }

  @override
  void update(
      void Function(GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdExport200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdExport200Response._(
            records: records.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'records';
        records.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdExport200Response',
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
