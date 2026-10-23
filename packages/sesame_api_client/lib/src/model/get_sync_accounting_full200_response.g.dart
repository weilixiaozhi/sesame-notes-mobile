// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_accounting_full200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncAccountingFull200Response
    extends GetSyncAccountingFull200Response {
  @override
  final BuiltList<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>
      ledgerSnapshots;
  @override
  final BuiltList<Category> categories;
  @override
  final BuiltList<ExchangeRateOverride> exchangeRateOverrides;
  @override
  final BuiltList<Category> categoryTombstones;
  @override
  final BuiltList<String> deletedExchangeRateOverrideIds;
  @override
  final String serverCursor;

  factory _$GetSyncAccountingFull200Response(
          [void Function(GetSyncAccountingFull200ResponseBuilder)? updates]) =>
      (GetSyncAccountingFull200ResponseBuilder()..update(updates))._build();

  _$GetSyncAccountingFull200Response._(
      {required this.ledgerSnapshots,
      required this.categories,
      required this.exchangeRateOverrides,
      required this.categoryTombstones,
      required this.deletedExchangeRateOverrideIds,
      required this.serverCursor})
      : super._();
  @override
  GetSyncAccountingFull200Response rebuild(
          void Function(GetSyncAccountingFull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncAccountingFull200ResponseBuilder toBuilder() =>
      GetSyncAccountingFull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncAccountingFull200Response &&
        ledgerSnapshots == other.ledgerSnapshots &&
        categories == other.categories &&
        exchangeRateOverrides == other.exchangeRateOverrides &&
        categoryTombstones == other.categoryTombstones &&
        deletedExchangeRateOverrideIds ==
            other.deletedExchangeRateOverrideIds &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerSnapshots.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, exchangeRateOverrides.hashCode);
    _$hash = $jc(_$hash, categoryTombstones.hashCode);
    _$hash = $jc(_$hash, deletedExchangeRateOverrideIds.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncAccountingFull200Response')
          ..add('ledgerSnapshots', ledgerSnapshots)
          ..add('categories', categories)
          ..add('exchangeRateOverrides', exchangeRateOverrides)
          ..add('categoryTombstones', categoryTombstones)
          ..add(
              'deletedExchangeRateOverrideIds', deletedExchangeRateOverrideIds)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncAccountingFull200ResponseBuilder
    implements
        Builder<GetSyncAccountingFull200Response,
            GetSyncAccountingFull200ResponseBuilder> {
  _$GetSyncAccountingFull200Response? _$v;

  ListBuilder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>?
      _ledgerSnapshots;
  ListBuilder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>
      get ledgerSnapshots => _$this._ledgerSnapshots ??=
          ListBuilder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>();
  set ledgerSnapshots(
          ListBuilder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>?
              ledgerSnapshots) =>
      _$this._ledgerSnapshots = ledgerSnapshots;

  ListBuilder<Category>? _categories;
  ListBuilder<Category> get categories =>
      _$this._categories ??= ListBuilder<Category>();
  set categories(ListBuilder<Category>? categories) =>
      _$this._categories = categories;

  ListBuilder<ExchangeRateOverride>? _exchangeRateOverrides;
  ListBuilder<ExchangeRateOverride> get exchangeRateOverrides =>
      _$this._exchangeRateOverrides ??= ListBuilder<ExchangeRateOverride>();
  set exchangeRateOverrides(
          ListBuilder<ExchangeRateOverride>? exchangeRateOverrides) =>
      _$this._exchangeRateOverrides = exchangeRateOverrides;

  ListBuilder<Category>? _categoryTombstones;
  ListBuilder<Category> get categoryTombstones =>
      _$this._categoryTombstones ??= ListBuilder<Category>();
  set categoryTombstones(ListBuilder<Category>? categoryTombstones) =>
      _$this._categoryTombstones = categoryTombstones;

  ListBuilder<String>? _deletedExchangeRateOverrideIds;
  ListBuilder<String> get deletedExchangeRateOverrideIds =>
      _$this._deletedExchangeRateOverrideIds ??= ListBuilder<String>();
  set deletedExchangeRateOverrideIds(
          ListBuilder<String>? deletedExchangeRateOverrideIds) =>
      _$this._deletedExchangeRateOverrideIds = deletedExchangeRateOverrideIds;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncAccountingFull200ResponseBuilder() {
    GetSyncAccountingFull200Response._defaults(this);
  }

  GetSyncAccountingFull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerSnapshots = $v.ledgerSnapshots.toBuilder();
      _categories = $v.categories.toBuilder();
      _exchangeRateOverrides = $v.exchangeRateOverrides.toBuilder();
      _categoryTombstones = $v.categoryTombstones.toBuilder();
      _deletedExchangeRateOverrideIds =
          $v.deletedExchangeRateOverrideIds.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncAccountingFull200Response other) {
    _$v = other as _$GetSyncAccountingFull200Response;
  }

  @override
  void update(void Function(GetSyncAccountingFull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncAccountingFull200Response build() => _build();

  _$GetSyncAccountingFull200Response _build() {
    _$GetSyncAccountingFull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncAccountingFull200Response._(
            ledgerSnapshots: ledgerSnapshots.build(),
            categories: categories.build(),
            exchangeRateOverrides: exchangeRateOverrides.build(),
            categoryTombstones: categoryTombstones.build(),
            deletedExchangeRateOverrideIds:
                deletedExchangeRateOverrideIds.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(serverCursor,
                r'GetSyncAccountingFull200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ledgerSnapshots';
        ledgerSnapshots.build();
        _$failedField = 'categories';
        categories.build();
        _$failedField = 'exchangeRateOverrides';
        exchangeRateOverrides.build();
        _$failedField = 'categoryTombstones';
        categoryTombstones.build();
        _$failedField = 'deletedExchangeRateOverrideIds';
        deletedExchangeRateOverrideIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncAccountingFull200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
