// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_details200_response_events_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_click =
    const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum._('click');
const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_complete =
    const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum._(
        'complete');

GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumValueOf(
        String name) {
  switch (name) {
    case 'click':
      return _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_click;
    case 'complete':
      return _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_complete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>
    _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumValues =
    BuiltSet<
        GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>(const <GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>[
  _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_click,
  _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_complete,
]);

Serializer<GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>
    _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumSerializer =
    _$GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumSerializer();

class _$GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'click': 'click',
    'complete': 'complete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'click': 'click',
    'complete': 'complete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
  ];
  @override
  final String wireName =
      'GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalyticsDetails200ResponseEventsInner
    extends GetAdminAnalyticsDetails200ResponseEventsInner {
  @override
  final String eventName;
  @override
  final String name;
  @override
  final GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum behavior;
  @override
  final int total;
  @override
  final int users;

  factory _$GetAdminAnalyticsDetails200ResponseEventsInner(
          [void Function(GetAdminAnalyticsDetails200ResponseEventsInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsDetails200ResponseEventsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAnalyticsDetails200ResponseEventsInner._(
      {required this.eventName,
      required this.name,
      required this.behavior,
      required this.total,
      required this.users})
      : super._();
  @override
  GetAdminAnalyticsDetails200ResponseEventsInner rebuild(
          void Function(GetAdminAnalyticsDetails200ResponseEventsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsDetails200ResponseEventsInnerBuilder toBuilder() =>
      GetAdminAnalyticsDetails200ResponseEventsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsDetails200ResponseEventsInner &&
        eventName == other.eventName &&
        name == other.name &&
        behavior == other.behavior &&
        total == other.total &&
        users == other.users;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, eventName.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, behavior.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, users.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsDetails200ResponseEventsInner')
          ..add('eventName', eventName)
          ..add('name', name)
          ..add('behavior', behavior)
          ..add('total', total)
          ..add('users', users))
        .toString();
  }
}

class GetAdminAnalyticsDetails200ResponseEventsInnerBuilder
    implements
        Builder<GetAdminAnalyticsDetails200ResponseEventsInner,
            GetAdminAnalyticsDetails200ResponseEventsInnerBuilder> {
  _$GetAdminAnalyticsDetails200ResponseEventsInner? _$v;

  String? _eventName;
  String? get eventName => _$this._eventName;
  set eventName(String? eventName) => _$this._eventName = eventName;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum? _behavior;
  GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum? get behavior =>
      _$this._behavior;
  set behavior(
          GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum?
              behavior) =>
      _$this._behavior = behavior;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _users;
  int? get users => _$this._users;
  set users(int? users) => _$this._users = users;

  GetAdminAnalyticsDetails200ResponseEventsInnerBuilder() {
    GetAdminAnalyticsDetails200ResponseEventsInner._defaults(this);
  }

  GetAdminAnalyticsDetails200ResponseEventsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _eventName = $v.eventName;
      _name = $v.name;
      _behavior = $v.behavior;
      _total = $v.total;
      _users = $v.users;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsDetails200ResponseEventsInner other) {
    _$v = other as _$GetAdminAnalyticsDetails200ResponseEventsInner;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsDetails200ResponseEventsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsDetails200ResponseEventsInner build() => _build();

  _$GetAdminAnalyticsDetails200ResponseEventsInner _build() {
    final _$result = _$v ??
        _$GetAdminAnalyticsDetails200ResponseEventsInner._(
          eventName: BuiltValueNullFieldError.checkNotNull(eventName,
              r'GetAdminAnalyticsDetails200ResponseEventsInner', 'eventName'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetAdminAnalyticsDetails200ResponseEventsInner', 'name'),
          behavior: BuiltValueNullFieldError.checkNotNull(behavior,
              r'GetAdminAnalyticsDetails200ResponseEventsInner', 'behavior'),
          total: BuiltValueNullFieldError.checkNotNull(total,
              r'GetAdminAnalyticsDetails200ResponseEventsInner', 'total'),
          users: BuiltValueNullFieldError.checkNotNull(users,
              r'GetAdminAnalyticsDetails200ResponseEventsInner', 'users'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
