// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_analytics_funnel_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminAnalyticsFunnelRequestPlatformEnum
    _$postAdminAnalyticsFunnelRequestPlatformEnum_all =
    const PostAdminAnalyticsFunnelRequestPlatformEnum._('all');
const PostAdminAnalyticsFunnelRequestPlatformEnum
    _$postAdminAnalyticsFunnelRequestPlatformEnum_app =
    const PostAdminAnalyticsFunnelRequestPlatformEnum._('app');
const PostAdminAnalyticsFunnelRequestPlatformEnum
    _$postAdminAnalyticsFunnelRequestPlatformEnum_web =
    const PostAdminAnalyticsFunnelRequestPlatformEnum._('web');

PostAdminAnalyticsFunnelRequestPlatformEnum
    _$postAdminAnalyticsFunnelRequestPlatformEnumValueOf(String name) {
  switch (name) {
    case 'all':
      return _$postAdminAnalyticsFunnelRequestPlatformEnum_all;
    case 'app':
      return _$postAdminAnalyticsFunnelRequestPlatformEnum_app;
    case 'web':
      return _$postAdminAnalyticsFunnelRequestPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAnalyticsFunnelRequestPlatformEnum>
    _$postAdminAnalyticsFunnelRequestPlatformEnumValues = BuiltSet<
        PostAdminAnalyticsFunnelRequestPlatformEnum>(const <PostAdminAnalyticsFunnelRequestPlatformEnum>[
  _$postAdminAnalyticsFunnelRequestPlatformEnum_all,
  _$postAdminAnalyticsFunnelRequestPlatformEnum_app,
  _$postAdminAnalyticsFunnelRequestPlatformEnum_web,
]);

const PostAdminAnalyticsFunnelRequestScopeEnum
    _$postAdminAnalyticsFunnelRequestScopeEnum_user =
    const PostAdminAnalyticsFunnelRequestScopeEnum._('user');
const PostAdminAnalyticsFunnelRequestScopeEnum
    _$postAdminAnalyticsFunnelRequestScopeEnum_session =
    const PostAdminAnalyticsFunnelRequestScopeEnum._('session');
const PostAdminAnalyticsFunnelRequestScopeEnum
    _$postAdminAnalyticsFunnelRequestScopeEnum_flow =
    const PostAdminAnalyticsFunnelRequestScopeEnum._('flow');

PostAdminAnalyticsFunnelRequestScopeEnum
    _$postAdminAnalyticsFunnelRequestScopeEnumValueOf(String name) {
  switch (name) {
    case 'user':
      return _$postAdminAnalyticsFunnelRequestScopeEnum_user;
    case 'session':
      return _$postAdminAnalyticsFunnelRequestScopeEnum_session;
    case 'flow':
      return _$postAdminAnalyticsFunnelRequestScopeEnum_flow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAnalyticsFunnelRequestScopeEnum>
    _$postAdminAnalyticsFunnelRequestScopeEnumValues = BuiltSet<
        PostAdminAnalyticsFunnelRequestScopeEnum>(const <PostAdminAnalyticsFunnelRequestScopeEnum>[
  _$postAdminAnalyticsFunnelRequestScopeEnum_user,
  _$postAdminAnalyticsFunnelRequestScopeEnum_session,
  _$postAdminAnalyticsFunnelRequestScopeEnum_flow,
]);

Serializer<PostAdminAnalyticsFunnelRequestPlatformEnum>
    _$postAdminAnalyticsFunnelRequestPlatformEnumSerializer =
    _$PostAdminAnalyticsFunnelRequestPlatformEnumSerializer();
Serializer<PostAdminAnalyticsFunnelRequestScopeEnum>
    _$postAdminAnalyticsFunnelRequestScopeEnumSerializer =
    _$PostAdminAnalyticsFunnelRequestScopeEnumSerializer();

class _$PostAdminAnalyticsFunnelRequestPlatformEnumSerializer
    implements
        PrimitiveSerializer<PostAdminAnalyticsFunnelRequestPlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'all': 'all',
    'app': 'app',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'all': 'all',
    'app': 'app',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAdminAnalyticsFunnelRequestPlatformEnum
  ];
  @override
  final String wireName = 'PostAdminAnalyticsFunnelRequestPlatformEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAnalyticsFunnelRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAnalyticsFunnelRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAnalyticsFunnelRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAnalyticsFunnelRequestScopeEnumSerializer
    implements PrimitiveSerializer<PostAdminAnalyticsFunnelRequestScopeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'user': 'user',
    'session': 'session',
    'flow': 'flow',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'user': 'user',
    'session': 'session',
    'flow': 'flow',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAdminAnalyticsFunnelRequestScopeEnum
  ];
  @override
  final String wireName = 'PostAdminAnalyticsFunnelRequestScopeEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAnalyticsFunnelRequestScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAnalyticsFunnelRequestScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAnalyticsFunnelRequestScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAnalyticsFunnelRequest
    extends PostAdminAnalyticsFunnelRequest {
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final PostAdminAnalyticsFunnelRequestPlatformEnum? platform;
  @override
  final BuiltList<String> steps;
  @override
  final PostAdminAnalyticsFunnelRequestScopeEnum scope;
  @override
  final int windowMinutes;

  factory _$PostAdminAnalyticsFunnelRequest(
          [void Function(PostAdminAnalyticsFunnelRequestBuilder)? updates]) =>
      (PostAdminAnalyticsFunnelRequestBuilder()..update(updates))._build();

  _$PostAdminAnalyticsFunnelRequest._(
      {required this.startDate,
      required this.endDate,
      this.platform,
      required this.steps,
      required this.scope,
      required this.windowMinutes})
      : super._();
  @override
  PostAdminAnalyticsFunnelRequest rebuild(
          void Function(PostAdminAnalyticsFunnelRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAnalyticsFunnelRequestBuilder toBuilder() =>
      PostAdminAnalyticsFunnelRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAnalyticsFunnelRequest &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        platform == other.platform &&
        steps == other.steps &&
        scope == other.scope &&
        windowMinutes == other.windowMinutes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, steps.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, windowMinutes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAnalyticsFunnelRequest')
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('platform', platform)
          ..add('steps', steps)
          ..add('scope', scope)
          ..add('windowMinutes', windowMinutes))
        .toString();
  }
}

class PostAdminAnalyticsFunnelRequestBuilder
    implements
        Builder<PostAdminAnalyticsFunnelRequest,
            PostAdminAnalyticsFunnelRequestBuilder> {
  _$PostAdminAnalyticsFunnelRequest? _$v;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  String? _endDate;
  String? get endDate => _$this._endDate;
  set endDate(String? endDate) => _$this._endDate = endDate;

  PostAdminAnalyticsFunnelRequestPlatformEnum? _platform;
  PostAdminAnalyticsFunnelRequestPlatformEnum? get platform => _$this._platform;
  set platform(PostAdminAnalyticsFunnelRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  ListBuilder<String>? _steps;
  ListBuilder<String> get steps => _$this._steps ??= ListBuilder<String>();
  set steps(ListBuilder<String>? steps) => _$this._steps = steps;

  PostAdminAnalyticsFunnelRequestScopeEnum? _scope;
  PostAdminAnalyticsFunnelRequestScopeEnum? get scope => _$this._scope;
  set scope(PostAdminAnalyticsFunnelRequestScopeEnum? scope) =>
      _$this._scope = scope;

  int? _windowMinutes;
  int? get windowMinutes => _$this._windowMinutes;
  set windowMinutes(int? windowMinutes) =>
      _$this._windowMinutes = windowMinutes;

  PostAdminAnalyticsFunnelRequestBuilder() {
    PostAdminAnalyticsFunnelRequest._defaults(this);
  }

  PostAdminAnalyticsFunnelRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _platform = $v.platform;
      _steps = $v.steps.toBuilder();
      _scope = $v.scope;
      _windowMinutes = $v.windowMinutes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAnalyticsFunnelRequest other) {
    _$v = other as _$PostAdminAnalyticsFunnelRequest;
  }

  @override
  void update(void Function(PostAdminAnalyticsFunnelRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAnalyticsFunnelRequest build() => _build();

  _$PostAdminAnalyticsFunnelRequest _build() {
    _$PostAdminAnalyticsFunnelRequest _$result;
    try {
      _$result = _$v ??
          _$PostAdminAnalyticsFunnelRequest._(
            startDate: BuiltValueNullFieldError.checkNotNull(
                startDate, r'PostAdminAnalyticsFunnelRequest', 'startDate'),
            endDate: BuiltValueNullFieldError.checkNotNull(
                endDate, r'PostAdminAnalyticsFunnelRequest', 'endDate'),
            platform: platform,
            steps: steps.build(),
            scope: BuiltValueNullFieldError.checkNotNull(
                scope, r'PostAdminAnalyticsFunnelRequest', 'scope'),
            windowMinutes: BuiltValueNullFieldError.checkNotNull(windowMinutes,
                r'PostAdminAnalyticsFunnelRequest', 'windowMinutes'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'steps';
        steps.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminAnalyticsFunnelRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
