// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessLibrary200Response extends GetFitnessLibrary200Response {
  @override
  final int schemaVersion;
  @override
  final int contentVersion;
  @override
  final BuiltList<GetFitnessLibrary200ResponseTemplatesInner> templates;
  @override
  final BuiltList<GetFitnessLibrary200ResponsePlansInner> plans;

  factory _$GetFitnessLibrary200Response(
          [void Function(GetFitnessLibrary200ResponseBuilder)? updates]) =>
      (GetFitnessLibrary200ResponseBuilder()..update(updates))._build();

  _$GetFitnessLibrary200Response._(
      {required this.schemaVersion,
      required this.contentVersion,
      required this.templates,
      required this.plans})
      : super._();
  @override
  GetFitnessLibrary200Response rebuild(
          void Function(GetFitnessLibrary200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponseBuilder toBuilder() =>
      GetFitnessLibrary200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200Response &&
        schemaVersion == other.schemaVersion &&
        contentVersion == other.contentVersion &&
        templates == other.templates &&
        plans == other.plans;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, contentVersion.hashCode);
    _$hash = $jc(_$hash, templates.hashCode);
    _$hash = $jc(_$hash, plans.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetFitnessLibrary200Response')
          ..add('schemaVersion', schemaVersion)
          ..add('contentVersion', contentVersion)
          ..add('templates', templates)
          ..add('plans', plans))
        .toString();
  }
}

class GetFitnessLibrary200ResponseBuilder
    implements
        Builder<GetFitnessLibrary200Response,
            GetFitnessLibrary200ResponseBuilder> {
  _$GetFitnessLibrary200Response? _$v;

  int? _schemaVersion;
  int? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(int? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  int? _contentVersion;
  int? get contentVersion => _$this._contentVersion;
  set contentVersion(int? contentVersion) =>
      _$this._contentVersion = contentVersion;

  ListBuilder<GetFitnessLibrary200ResponseTemplatesInner>? _templates;
  ListBuilder<GetFitnessLibrary200ResponseTemplatesInner> get templates =>
      _$this._templates ??=
          ListBuilder<GetFitnessLibrary200ResponseTemplatesInner>();
  set templates(
          ListBuilder<GetFitnessLibrary200ResponseTemplatesInner>? templates) =>
      _$this._templates = templates;

  ListBuilder<GetFitnessLibrary200ResponsePlansInner>? _plans;
  ListBuilder<GetFitnessLibrary200ResponsePlansInner> get plans =>
      _$this._plans ??= ListBuilder<GetFitnessLibrary200ResponsePlansInner>();
  set plans(ListBuilder<GetFitnessLibrary200ResponsePlansInner>? plans) =>
      _$this._plans = plans;

  GetFitnessLibrary200ResponseBuilder() {
    GetFitnessLibrary200Response._defaults(this);
  }

  GetFitnessLibrary200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _schemaVersion = $v.schemaVersion;
      _contentVersion = $v.contentVersion;
      _templates = $v.templates.toBuilder();
      _plans = $v.plans.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200Response other) {
    _$v = other as _$GetFitnessLibrary200Response;
  }

  @override
  void update(void Function(GetFitnessLibrary200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200Response build() => _build();

  _$GetFitnessLibrary200Response _build() {
    _$GetFitnessLibrary200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessLibrary200Response._(
            schemaVersion: BuiltValueNullFieldError.checkNotNull(schemaVersion,
                r'GetFitnessLibrary200Response', 'schemaVersion'),
            contentVersion: BuiltValueNullFieldError.checkNotNull(
                contentVersion,
                r'GetFitnessLibrary200Response',
                'contentVersion'),
            templates: templates.build(),
            plans: plans.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'templates';
        templates.build();
        _$failedField = 'plans';
        plans.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessLibrary200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
