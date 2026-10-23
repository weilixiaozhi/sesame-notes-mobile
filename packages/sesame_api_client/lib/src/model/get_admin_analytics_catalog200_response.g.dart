// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_catalog200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalyticsCatalog200Response
    extends GetAdminAnalyticsCatalog200Response {
  @override
  final BuiltList<GetAdminAnalyticsCatalog200ResponseEventsInner> events;

  factory _$GetAdminAnalyticsCatalog200Response(
          [void Function(GetAdminAnalyticsCatalog200ResponseBuilder)?
              updates]) =>
      (GetAdminAnalyticsCatalog200ResponseBuilder()..update(updates))._build();

  _$GetAdminAnalyticsCatalog200Response._({required this.events}) : super._();
  @override
  GetAdminAnalyticsCatalog200Response rebuild(
          void Function(GetAdminAnalyticsCatalog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsCatalog200ResponseBuilder toBuilder() =>
      GetAdminAnalyticsCatalog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsCatalog200Response &&
        events == other.events;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAnalyticsCatalog200Response')
          ..add('events', events))
        .toString();
  }
}

class GetAdminAnalyticsCatalog200ResponseBuilder
    implements
        Builder<GetAdminAnalyticsCatalog200Response,
            GetAdminAnalyticsCatalog200ResponseBuilder> {
  _$GetAdminAnalyticsCatalog200Response? _$v;

  ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInner>? _events;
  ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInner> get events =>
      _$this._events ??=
          ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInner>();
  set events(
          ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInner>?
              events) =>
      _$this._events = events;

  GetAdminAnalyticsCatalog200ResponseBuilder() {
    GetAdminAnalyticsCatalog200Response._defaults(this);
  }

  GetAdminAnalyticsCatalog200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsCatalog200Response other) {
    _$v = other as _$GetAdminAnalyticsCatalog200Response;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsCatalog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsCatalog200Response build() => _build();

  _$GetAdminAnalyticsCatalog200Response _build() {
    _$GetAdminAnalyticsCatalog200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminAnalyticsCatalog200Response._(
            events: events.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GetAdminAnalyticsCatalog200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
