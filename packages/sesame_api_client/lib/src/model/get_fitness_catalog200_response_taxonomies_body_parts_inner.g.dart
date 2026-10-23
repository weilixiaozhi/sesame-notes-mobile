// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_catalog200_response_taxonomies_body_parts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner
    extends GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner {
  @override
  final String id;
  @override
  final ListOfficialFitnessTaxonomies200ResponseItemsInnerName name;
  @override
  final bool isDeleted;

  factory _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner(
          [void Function(
                  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder)?
              updates]) =>
      (GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner._(
      {required this.id, required this.name, required this.isDeleted})
      : super._();
  @override
  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner rebuild(
          void Function(
                  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder toBuilder() =>
      GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner &&
        id == other.id &&
        name == other.name &&
        isDeleted == other.isDeleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isDeleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('isDeleted', isDeleted))
        .toString();
  }
}

class GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder
    implements
        Builder<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner,
            GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder> {
  _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder? _name;
  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder get name =>
      _$this._name ??=
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder();
  set name(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder?
              name) =>
      _$this._name = name;

  bool? _isDeleted;
  bool? get isDeleted => _$this._isDeleted;
  set isDeleted(bool? isDeleted) => _$this._isDeleted = isDeleted;

  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder() {
    GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner._defaults(this);
  }

  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name.toBuilder();
      _isDeleted = $v.isDeleted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner other) {
    _$v = other as _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner build() => _build();

  _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner _build() {
    _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner._(
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner', 'id'),
            name: name.build(),
            isDeleted: BuiltValueNullFieldError.checkNotNull(
                isDeleted,
                r'GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner',
                'isDeleted'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        name.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner',
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
