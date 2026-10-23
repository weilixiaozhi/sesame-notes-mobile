// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_catalog200_response_taxonomies.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessCatalog200ResponseTaxonomies
    extends GetFitnessCatalog200ResponseTaxonomies {
  @override
  final BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>
      bodyParts;
  @override
  final BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>
      equipment;

  factory _$GetFitnessCatalog200ResponseTaxonomies(
          [void Function(GetFitnessCatalog200ResponseTaxonomiesBuilder)?
              updates]) =>
      (GetFitnessCatalog200ResponseTaxonomiesBuilder()..update(updates))
          ._build();

  _$GetFitnessCatalog200ResponseTaxonomies._(
      {required this.bodyParts, required this.equipment})
      : super._();
  @override
  GetFitnessCatalog200ResponseTaxonomies rebuild(
          void Function(GetFitnessCatalog200ResponseTaxonomiesBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessCatalog200ResponseTaxonomiesBuilder toBuilder() =>
      GetFitnessCatalog200ResponseTaxonomiesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessCatalog200ResponseTaxonomies &&
        bodyParts == other.bodyParts &&
        equipment == other.equipment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bodyParts.hashCode);
    _$hash = $jc(_$hash, equipment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessCatalog200ResponseTaxonomies')
          ..add('bodyParts', bodyParts)
          ..add('equipment', equipment))
        .toString();
  }
}

class GetFitnessCatalog200ResponseTaxonomiesBuilder
    implements
        Builder<GetFitnessCatalog200ResponseTaxonomies,
            GetFitnessCatalog200ResponseTaxonomiesBuilder> {
  _$GetFitnessCatalog200ResponseTaxonomies? _$v;

  ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>? _bodyParts;
  ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>
      get bodyParts => _$this._bodyParts ??=
          ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>();
  set bodyParts(
          ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>?
              bodyParts) =>
      _$this._bodyParts = bodyParts;

  ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>? _equipment;
  ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>
      get equipment => _$this._equipment ??=
          ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>();
  set equipment(
          ListBuilder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>?
              equipment) =>
      _$this._equipment = equipment;

  GetFitnessCatalog200ResponseTaxonomiesBuilder() {
    GetFitnessCatalog200ResponseTaxonomies._defaults(this);
  }

  GetFitnessCatalog200ResponseTaxonomiesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bodyParts = $v.bodyParts.toBuilder();
      _equipment = $v.equipment.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessCatalog200ResponseTaxonomies other) {
    _$v = other as _$GetFitnessCatalog200ResponseTaxonomies;
  }

  @override
  void update(
      void Function(GetFitnessCatalog200ResponseTaxonomiesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessCatalog200ResponseTaxonomies build() => _build();

  _$GetFitnessCatalog200ResponseTaxonomies _build() {
    _$GetFitnessCatalog200ResponseTaxonomies _$result;
    try {
      _$result = _$v ??
          _$GetFitnessCatalog200ResponseTaxonomies._(
            bodyParts: bodyParts.build(),
            equipment: equipment.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bodyParts';
        bodyParts.build();
        _$failedField = 'equipment';
        equipment.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessCatalog200ResponseTaxonomies',
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
