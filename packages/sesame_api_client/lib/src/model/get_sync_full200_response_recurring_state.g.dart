// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response_recurring_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFull200ResponseRecurringState
    extends GetSyncFull200ResponseRecurringState {
  @override
  final BuiltList<GetSyncFull200ResponseRecurringStateRulesInner> rules;
  @override
  final BuiltList<GetSyncFull200ResponseRecurringStateOccurrencesInner>
      occurrences;

  factory _$GetSyncFull200ResponseRecurringState(
          [void Function(GetSyncFull200ResponseRecurringStateBuilder)?
              updates]) =>
      (GetSyncFull200ResponseRecurringStateBuilder()..update(updates))._build();

  _$GetSyncFull200ResponseRecurringState._(
      {required this.rules, required this.occurrences})
      : super._();
  @override
  GetSyncFull200ResponseRecurringState rebuild(
          void Function(GetSyncFull200ResponseRecurringStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFull200ResponseRecurringStateBuilder toBuilder() =>
      GetSyncFull200ResponseRecurringStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFull200ResponseRecurringState &&
        rules == other.rules &&
        occurrences == other.occurrences;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rules.hashCode);
    _$hash = $jc(_$hash, occurrences.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFull200ResponseRecurringState')
          ..add('rules', rules)
          ..add('occurrences', occurrences))
        .toString();
  }
}

class GetSyncFull200ResponseRecurringStateBuilder
    implements
        Builder<GetSyncFull200ResponseRecurringState,
            GetSyncFull200ResponseRecurringStateBuilder> {
  _$GetSyncFull200ResponseRecurringState? _$v;

  ListBuilder<GetSyncFull200ResponseRecurringStateRulesInner>? _rules;
  ListBuilder<GetSyncFull200ResponseRecurringStateRulesInner> get rules =>
      _$this._rules ??=
          ListBuilder<GetSyncFull200ResponseRecurringStateRulesInner>();
  set rules(
          ListBuilder<GetSyncFull200ResponseRecurringStateRulesInner>? rules) =>
      _$this._rules = rules;

  ListBuilder<GetSyncFull200ResponseRecurringStateOccurrencesInner>?
      _occurrences;
  ListBuilder<GetSyncFull200ResponseRecurringStateOccurrencesInner>
      get occurrences => _$this._occurrences ??=
          ListBuilder<GetSyncFull200ResponseRecurringStateOccurrencesInner>();
  set occurrences(
          ListBuilder<GetSyncFull200ResponseRecurringStateOccurrencesInner>?
              occurrences) =>
      _$this._occurrences = occurrences;

  GetSyncFull200ResponseRecurringStateBuilder() {
    GetSyncFull200ResponseRecurringState._defaults(this);
  }

  GetSyncFull200ResponseRecurringStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rules = $v.rules.toBuilder();
      _occurrences = $v.occurrences.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFull200ResponseRecurringState other) {
    _$v = other as _$GetSyncFull200ResponseRecurringState;
  }

  @override
  void update(
      void Function(GetSyncFull200ResponseRecurringStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFull200ResponseRecurringState build() => _build();

  _$GetSyncFull200ResponseRecurringState _build() {
    _$GetSyncFull200ResponseRecurringState _$result;
    try {
      _$result = _$v ??
          _$GetSyncFull200ResponseRecurringState._(
            rules: rules.build(),
            occurrences: occurrences.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rules';
        rules.build();
        _$failedField = 'occurrences';
        occurrences.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncFull200ResponseRecurringState',
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
