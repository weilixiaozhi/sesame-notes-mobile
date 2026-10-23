// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_shared_resources200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdSharedResources200Response
    extends GetLedgersByLedgerIdSharedResources200Response {
  @override
  final String ownerUserId;
  @override
  final BuiltList<Category> categories;

  factory _$GetLedgersByLedgerIdSharedResources200Response(
          [void Function(GetLedgersByLedgerIdSharedResources200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdSharedResources200ResponseBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdSharedResources200Response._(
      {required this.ownerUserId, required this.categories})
      : super._();
  @override
  GetLedgersByLedgerIdSharedResources200Response rebuild(
          void Function(GetLedgersByLedgerIdSharedResources200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdSharedResources200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdSharedResources200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdSharedResources200Response &&
        ownerUserId == other.ownerUserId &&
        categories == other.categories;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ownerUserId.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdSharedResources200Response')
          ..add('ownerUserId', ownerUserId)
          ..add('categories', categories))
        .toString();
  }
}

class GetLedgersByLedgerIdSharedResources200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdSharedResources200Response,
            GetLedgersByLedgerIdSharedResources200ResponseBuilder> {
  _$GetLedgersByLedgerIdSharedResources200Response? _$v;

  String? _ownerUserId;
  String? get ownerUserId => _$this._ownerUserId;
  set ownerUserId(String? ownerUserId) => _$this._ownerUserId = ownerUserId;

  ListBuilder<Category>? _categories;
  ListBuilder<Category> get categories =>
      _$this._categories ??= ListBuilder<Category>();
  set categories(ListBuilder<Category>? categories) =>
      _$this._categories = categories;

  GetLedgersByLedgerIdSharedResources200ResponseBuilder() {
    GetLedgersByLedgerIdSharedResources200Response._defaults(this);
  }

  GetLedgersByLedgerIdSharedResources200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ownerUserId = $v.ownerUserId;
      _categories = $v.categories.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdSharedResources200Response other) {
    _$v = other as _$GetLedgersByLedgerIdSharedResources200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdSharedResources200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdSharedResources200Response build() => _build();

  _$GetLedgersByLedgerIdSharedResources200Response _build() {
    _$GetLedgersByLedgerIdSharedResources200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdSharedResources200Response._(
            ownerUserId: BuiltValueNullFieldError.checkNotNull(
                ownerUserId,
                r'GetLedgersByLedgerIdSharedResources200Response',
                'ownerUserId'),
            categories: categories.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categories';
        categories.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetLedgersByLedgerIdSharedResources200Response',
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
