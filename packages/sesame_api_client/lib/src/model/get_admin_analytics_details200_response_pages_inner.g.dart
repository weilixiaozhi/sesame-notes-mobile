// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_details200_response_pages_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAnalyticsDetails200ResponsePagesInner
    extends GetAdminAnalyticsDetails200ResponsePagesInner {
  @override
  final String pageId;
  @override
  final String eventName;
  @override
  final String name;
  @override
  final int pageViews;
  @override
  final int visitors;

  factory _$GetAdminAnalyticsDetails200ResponsePagesInner(
          [void Function(GetAdminAnalyticsDetails200ResponsePagesInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsDetails200ResponsePagesInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAnalyticsDetails200ResponsePagesInner._(
      {required this.pageId,
      required this.eventName,
      required this.name,
      required this.pageViews,
      required this.visitors})
      : super._();
  @override
  GetAdminAnalyticsDetails200ResponsePagesInner rebuild(
          void Function(GetAdminAnalyticsDetails200ResponsePagesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsDetails200ResponsePagesInnerBuilder toBuilder() =>
      GetAdminAnalyticsDetails200ResponsePagesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsDetails200ResponsePagesInner &&
        pageId == other.pageId &&
        eventName == other.eventName &&
        name == other.name &&
        pageViews == other.pageViews &&
        visitors == other.visitors;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pageId.hashCode);
    _$hash = $jc(_$hash, eventName.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, pageViews.hashCode);
    _$hash = $jc(_$hash, visitors.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsDetails200ResponsePagesInner')
          ..add('pageId', pageId)
          ..add('eventName', eventName)
          ..add('name', name)
          ..add('pageViews', pageViews)
          ..add('visitors', visitors))
        .toString();
  }
}

class GetAdminAnalyticsDetails200ResponsePagesInnerBuilder
    implements
        Builder<GetAdminAnalyticsDetails200ResponsePagesInner,
            GetAdminAnalyticsDetails200ResponsePagesInnerBuilder> {
  _$GetAdminAnalyticsDetails200ResponsePagesInner? _$v;

  String? _pageId;
  String? get pageId => _$this._pageId;
  set pageId(String? pageId) => _$this._pageId = pageId;

  String? _eventName;
  String? get eventName => _$this._eventName;
  set eventName(String? eventName) => _$this._eventName = eventName;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _pageViews;
  int? get pageViews => _$this._pageViews;
  set pageViews(int? pageViews) => _$this._pageViews = pageViews;

  int? _visitors;
  int? get visitors => _$this._visitors;
  set visitors(int? visitors) => _$this._visitors = visitors;

  GetAdminAnalyticsDetails200ResponsePagesInnerBuilder() {
    GetAdminAnalyticsDetails200ResponsePagesInner._defaults(this);
  }

  GetAdminAnalyticsDetails200ResponsePagesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pageId = $v.pageId;
      _eventName = $v.eventName;
      _name = $v.name;
      _pageViews = $v.pageViews;
      _visitors = $v.visitors;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsDetails200ResponsePagesInner other) {
    _$v = other as _$GetAdminAnalyticsDetails200ResponsePagesInner;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsDetails200ResponsePagesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsDetails200ResponsePagesInner build() => _build();

  _$GetAdminAnalyticsDetails200ResponsePagesInner _build() {
    final _$result = _$v ??
        _$GetAdminAnalyticsDetails200ResponsePagesInner._(
          pageId: BuiltValueNullFieldError.checkNotNull(pageId,
              r'GetAdminAnalyticsDetails200ResponsePagesInner', 'pageId'),
          eventName: BuiltValueNullFieldError.checkNotNull(eventName,
              r'GetAdminAnalyticsDetails200ResponsePagesInner', 'eventName'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetAdminAnalyticsDetails200ResponsePagesInner', 'name'),
          pageViews: BuiltValueNullFieldError.checkNotNull(pageViews,
              r'GetAdminAnalyticsDetails200ResponsePagesInner', 'pageViews'),
          visitors: BuiltValueNullFieldError.checkNotNull(visitors,
              r'GetAdminAnalyticsDetails200ResponsePagesInner', 'visitors'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
