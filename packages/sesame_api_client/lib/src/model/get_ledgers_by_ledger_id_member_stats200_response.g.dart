// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_member_stats200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_month =
    const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum._('month');
const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_year =
    const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum._('year');
const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_all =
    const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum._('all');

GetLedgersByLedgerIdMemberStats200ResponseScopeEnum
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumValueOf(String name) {
  switch (name) {
    case 'month':
      return _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_month;
    case 'year':
      return _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_year;
    case 'all':
      return _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_all;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumValues = BuiltSet<
        GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>(const <GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>[
  _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_month,
  _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_year,
  _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_all,
]);

Serializer<GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>
    _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumSerializer =
    _$GetLedgersByLedgerIdMemberStats200ResponseScopeEnumSerializer();

class _$GetLedgersByLedgerIdMemberStats200ResponseScopeEnumSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdMemberStats200ResponseScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'month': 'month',
    'year': 'year',
    'all': 'all',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'month': 'month',
    'year': 'year',
    'all': 'all',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetLedgersByLedgerIdMemberStats200ResponseScopeEnum
  ];
  @override
  final String wireName = 'GetLedgersByLedgerIdMemberStats200ResponseScopeEnum';

  @override
  Object serialize(Serializers serializers,
          GetLedgersByLedgerIdMemberStats200ResponseScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetLedgersByLedgerIdMemberStats200ResponseScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetLedgersByLedgerIdMemberStats200ResponseScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetLedgersByLedgerIdMemberStats200Response
    extends GetLedgersByLedgerIdMemberStats200Response {
  @override
  final String ledgerId;
  @override
  final String ledgerCurrency;
  @override
  final GetLedgersByLedgerIdMemberStats200ResponseScopeEnum scope;
  @override
  final String? period;
  @override
  final DateTime? startAt;
  @override
  final DateTime? endAt;
  @override
  final BuiltList<GetLedgersByLedgerIdMemberStats200ResponseItemsInner> items;

  factory _$GetLedgersByLedgerIdMemberStats200Response(
          [void Function(GetLedgersByLedgerIdMemberStats200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdMemberStats200ResponseBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdMemberStats200Response._(
      {required this.ledgerId,
      required this.ledgerCurrency,
      required this.scope,
      this.period,
      this.startAt,
      this.endAt,
      required this.items})
      : super._();
  @override
  GetLedgersByLedgerIdMemberStats200Response rebuild(
          void Function(GetLedgersByLedgerIdMemberStats200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdMemberStats200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdMemberStats200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdMemberStats200Response &&
        ledgerId == other.ledgerId &&
        ledgerCurrency == other.ledgerCurrency &&
        scope == other.scope &&
        period == other.period &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, ledgerCurrency.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, period.hashCode);
    _$hash = $jc(_$hash, startAt.hashCode);
    _$hash = $jc(_$hash, endAt.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdMemberStats200Response')
          ..add('ledgerId', ledgerId)
          ..add('ledgerCurrency', ledgerCurrency)
          ..add('scope', scope)
          ..add('period', period)
          ..add('startAt', startAt)
          ..add('endAt', endAt)
          ..add('items', items))
        .toString();
  }
}

class GetLedgersByLedgerIdMemberStats200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdMemberStats200Response,
            GetLedgersByLedgerIdMemberStats200ResponseBuilder> {
  _$GetLedgersByLedgerIdMemberStats200Response? _$v;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _ledgerCurrency;
  String? get ledgerCurrency => _$this._ledgerCurrency;
  set ledgerCurrency(String? ledgerCurrency) =>
      _$this._ledgerCurrency = ledgerCurrency;

  GetLedgersByLedgerIdMemberStats200ResponseScopeEnum? _scope;
  GetLedgersByLedgerIdMemberStats200ResponseScopeEnum? get scope =>
      _$this._scope;
  set scope(GetLedgersByLedgerIdMemberStats200ResponseScopeEnum? scope) =>
      _$this._scope = scope;

  String? _period;
  String? get period => _$this._period;
  set period(String? period) => _$this._period = period;

  DateTime? _startAt;
  DateTime? get startAt => _$this._startAt;
  set startAt(DateTime? startAt) => _$this._startAt = startAt;

  DateTime? _endAt;
  DateTime? get endAt => _$this._endAt;
  set endAt(DateTime? endAt) => _$this._endAt = endAt;

  ListBuilder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>? _items;
  ListBuilder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>();
  set items(
          ListBuilder<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  GetLedgersByLedgerIdMemberStats200ResponseBuilder() {
    GetLedgersByLedgerIdMemberStats200Response._defaults(this);
  }

  GetLedgersByLedgerIdMemberStats200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerId = $v.ledgerId;
      _ledgerCurrency = $v.ledgerCurrency;
      _scope = $v.scope;
      _period = $v.period;
      _startAt = $v.startAt;
      _endAt = $v.endAt;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdMemberStats200Response other) {
    _$v = other as _$GetLedgersByLedgerIdMemberStats200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdMemberStats200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdMemberStats200Response build() => _build();

  _$GetLedgersByLedgerIdMemberStats200Response _build() {
    _$GetLedgersByLedgerIdMemberStats200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdMemberStats200Response._(
            ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
                r'GetLedgersByLedgerIdMemberStats200Response', 'ledgerId'),
            ledgerCurrency: BuiltValueNullFieldError.checkNotNull(
                ledgerCurrency,
                r'GetLedgersByLedgerIdMemberStats200Response',
                'ledgerCurrency'),
            scope: BuiltValueNullFieldError.checkNotNull(
                scope, r'GetLedgersByLedgerIdMemberStats200Response', 'scope'),
            period: period,
            startAt: startAt,
            endAt: endAt,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetLedgersByLedgerIdMemberStats200Response',
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
