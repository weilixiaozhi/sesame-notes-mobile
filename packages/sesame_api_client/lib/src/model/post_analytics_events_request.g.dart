// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_analytics_events_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAnalyticsEventsRequest extends PostAnalyticsEventsRequest {
  @override
  final BuiltList<PostAnalyticsEventsRequestEventsInner> events;

  factory _$PostAnalyticsEventsRequest(
          [void Function(PostAnalyticsEventsRequestBuilder)? updates]) =>
      (PostAnalyticsEventsRequestBuilder()..update(updates))._build();

  _$PostAnalyticsEventsRequest._({required this.events}) : super._();
  @override
  PostAnalyticsEventsRequest rebuild(
          void Function(PostAnalyticsEventsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAnalyticsEventsRequestBuilder toBuilder() =>
      PostAnalyticsEventsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAnalyticsEventsRequest && events == other.events;
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
    return (newBuiltValueToStringHelper(r'PostAnalyticsEventsRequest')
          ..add('events', events))
        .toString();
  }
}

class PostAnalyticsEventsRequestBuilder
    implements
        Builder<PostAnalyticsEventsRequest, PostAnalyticsEventsRequestBuilder> {
  _$PostAnalyticsEventsRequest? _$v;

  ListBuilder<PostAnalyticsEventsRequestEventsInner>? _events;
  ListBuilder<PostAnalyticsEventsRequestEventsInner> get events =>
      _$this._events ??= ListBuilder<PostAnalyticsEventsRequestEventsInner>();
  set events(ListBuilder<PostAnalyticsEventsRequestEventsInner>? events) =>
      _$this._events = events;

  PostAnalyticsEventsRequestBuilder() {
    PostAnalyticsEventsRequest._defaults(this);
  }

  PostAnalyticsEventsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAnalyticsEventsRequest other) {
    _$v = other as _$PostAnalyticsEventsRequest;
  }

  @override
  void update(void Function(PostAnalyticsEventsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAnalyticsEventsRequest build() => _build();

  _$PostAnalyticsEventsRequest _build() {
    _$PostAnalyticsEventsRequest _$result;
    try {
      _$result = _$v ??
          _$PostAnalyticsEventsRequest._(
            events: events.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        events.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAnalyticsEventsRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
