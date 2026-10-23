// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_analytics_catalog200_response_events_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_pageView =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum._('pageView');
const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_action =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum._('action');

GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'pageView':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_pageView;
    case 'action':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_action;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumValues = BuiltSet<
        GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>(const <GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>[
  _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_pageView,
  _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_action,
]);

const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_view =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum._('view');
const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_click =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum._('click');
const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_complete =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum._(
        'complete');

GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumValueOf(
        String name) {
  switch (name) {
    case 'view':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_view;
    case 'click':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_click;
    case 'complete':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_complete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumValues =
    BuiltSet<
        GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>(const <GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>[
  _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_view,
  _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_click,
  _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_complete,
]);

const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_app =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum._('app');
const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_web =
    const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum._('web');

GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
    _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumValueOf(
        String name) {
  switch (name) {
    case 'app':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_app;
    case 'web':
      return _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumValues =
    BuiltSet<
        GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>(const <GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>[
  _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_app,
  _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_web,
]);

Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumSerializer =
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnumSerializer();
Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumSerializer =
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumSerializer();
Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
    _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumSerializer =
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumSerializer();

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pageView': 'page_view',
    'action': 'action',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'page_view': 'pageView',
    'action': 'action',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum
  ];
  @override
  final String wireName =
      'GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'view': 'view',
    'click': 'click',
    'complete': 'complete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'view': 'view',
    'click': 'click',
    'complete': 'complete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
  ];
  @override
  final String wireName =
      'GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'app': 'app',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'app': 'app',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
  ];
  @override
  final String wireName =
      'GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInner
    extends GetAdminAnalyticsCatalog200ResponseEventsInner {
  @override
  final String id;
  @override
  final String eventName;
  @override
  final String? pageId;
  @override
  final GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum kind;
  @override
  final GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum behavior;
  @override
  final String name;
  @override
  final String location;
  @override
  final BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
      platforms;
  @override
  final BuiltList<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>
      sourcePages;

  factory _$GetAdminAnalyticsCatalog200ResponseEventsInner(
          [void Function(GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder)?
              updates]) =>
      (GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminAnalyticsCatalog200ResponseEventsInner._(
      {required this.id,
      required this.eventName,
      this.pageId,
      required this.kind,
      required this.behavior,
      required this.name,
      required this.location,
      required this.platforms,
      required this.sourcePages})
      : super._();
  @override
  GetAdminAnalyticsCatalog200ResponseEventsInner rebuild(
          void Function(GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder toBuilder() =>
      GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAnalyticsCatalog200ResponseEventsInner &&
        id == other.id &&
        eventName == other.eventName &&
        pageId == other.pageId &&
        kind == other.kind &&
        behavior == other.behavior &&
        name == other.name &&
        location == other.location &&
        platforms == other.platforms &&
        sourcePages == other.sourcePages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, eventName.hashCode);
    _$hash = $jc(_$hash, pageId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, behavior.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, platforms.hashCode);
    _$hash = $jc(_$hash, sourcePages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminAnalyticsCatalog200ResponseEventsInner')
          ..add('id', id)
          ..add('eventName', eventName)
          ..add('pageId', pageId)
          ..add('kind', kind)
          ..add('behavior', behavior)
          ..add('name', name)
          ..add('location', location)
          ..add('platforms', platforms)
          ..add('sourcePages', sourcePages))
        .toString();
  }
}

class GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder
    implements
        Builder<GetAdminAnalyticsCatalog200ResponseEventsInner,
            GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder> {
  _$GetAdminAnalyticsCatalog200ResponseEventsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _eventName;
  String? get eventName => _$this._eventName;
  set eventName(String? eventName) => _$this._eventName = eventName;

  String? _pageId;
  String? get pageId => _$this._pageId;
  set pageId(String? pageId) => _$this._pageId = pageId;

  GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum? _kind;
  GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum? get kind =>
      _$this._kind;
  set kind(GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum? kind) =>
      _$this._kind = kind;

  GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum? _behavior;
  GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum? get behavior =>
      _$this._behavior;
  set behavior(
          GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum?
              behavior) =>
      _$this._behavior = behavior;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _location;
  String? get location => _$this._location;
  set location(String? location) => _$this._location = location;

  SetBuilder<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>?
      _platforms;
  SetBuilder<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
      get platforms => _$this._platforms ??= SetBuilder<
          GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>();
  set platforms(
          SetBuilder<
                  GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>?
              platforms) =>
      _$this._platforms = platforms;

  ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>?
      _sourcePages;
  ListBuilder<GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>
      get sourcePages => _$this._sourcePages ??= ListBuilder<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>();
  set sourcePages(
          ListBuilder<
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>?
              sourcePages) =>
      _$this._sourcePages = sourcePages;

  GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder() {
    GetAdminAnalyticsCatalog200ResponseEventsInner._defaults(this);
  }

  GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _eventName = $v.eventName;
      _pageId = $v.pageId;
      _kind = $v.kind;
      _behavior = $v.behavior;
      _name = $v.name;
      _location = $v.location;
      _platforms = $v.platforms.toBuilder();
      _sourcePages = $v.sourcePages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAnalyticsCatalog200ResponseEventsInner other) {
    _$v = other as _$GetAdminAnalyticsCatalog200ResponseEventsInner;
  }

  @override
  void update(
      void Function(GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInner build() => _build();

  _$GetAdminAnalyticsCatalog200ResponseEventsInner _build() {
    _$GetAdminAnalyticsCatalog200ResponseEventsInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminAnalyticsCatalog200ResponseEventsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'id'),
            eventName: BuiltValueNullFieldError.checkNotNull(eventName,
                r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'eventName'),
            pageId: pageId,
            kind: BuiltValueNullFieldError.checkNotNull(kind,
                r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'kind'),
            behavior: BuiltValueNullFieldError.checkNotNull(behavior,
                r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'behavior'),
            name: BuiltValueNullFieldError.checkNotNull(name,
                r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'name'),
            location: BuiltValueNullFieldError.checkNotNull(location,
                r'GetAdminAnalyticsCatalog200ResponseEventsInner', 'location'),
            platforms: platforms.build(),
            sourcePages: sourcePages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'platforms';
        platforms.build();
        _$failedField = 'sourcePages';
        sourcePages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminAnalyticsCatalog200ResponseEventsInner',
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
