// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_fitness_taxonomies200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListOfficialFitnessTaxonomies200Response
    extends ListOfficialFitnessTaxonomies200Response {
  @override
  final BuiltList<ListOfficialFitnessTaxonomies200ResponseItemsInner> items;

  factory _$ListOfficialFitnessTaxonomies200Response(
          [void Function(ListOfficialFitnessTaxonomies200ResponseBuilder)?
              updates]) =>
      (ListOfficialFitnessTaxonomies200ResponseBuilder()..update(updates))
          ._build();

  _$ListOfficialFitnessTaxonomies200Response._({required this.items})
      : super._();
  @override
  ListOfficialFitnessTaxonomies200Response rebuild(
          void Function(ListOfficialFitnessTaxonomies200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialFitnessTaxonomies200ResponseBuilder toBuilder() =>
      ListOfficialFitnessTaxonomies200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialFitnessTaxonomies200Response &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListOfficialFitnessTaxonomies200Response')
          ..add('items', items))
        .toString();
  }
}

class ListOfficialFitnessTaxonomies200ResponseBuilder
    implements
        Builder<ListOfficialFitnessTaxonomies200Response,
            ListOfficialFitnessTaxonomies200ResponseBuilder> {
  _$ListOfficialFitnessTaxonomies200Response? _$v;

  ListBuilder<ListOfficialFitnessTaxonomies200ResponseItemsInner>? _items;
  ListBuilder<ListOfficialFitnessTaxonomies200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<ListOfficialFitnessTaxonomies200ResponseItemsInner>();
  set items(
          ListBuilder<ListOfficialFitnessTaxonomies200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  ListOfficialFitnessTaxonomies200ResponseBuilder() {
    ListOfficialFitnessTaxonomies200Response._defaults(this);
  }

  ListOfficialFitnessTaxonomies200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialFitnessTaxonomies200Response other) {
    _$v = other as _$ListOfficialFitnessTaxonomies200Response;
  }

  @override
  void update(
      void Function(ListOfficialFitnessTaxonomies200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialFitnessTaxonomies200Response build() => _build();

  _$ListOfficialFitnessTaxonomies200Response _build() {
    _$ListOfficialFitnessTaxonomies200Response _$result;
    try {
      _$result = _$v ??
          _$ListOfficialFitnessTaxonomies200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialFitnessTaxonomies200Response',
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
