// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_analytics_funnel200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminAnalyticsFunnel200ResponseScopeEnum
    _$postAdminAnalyticsFunnel200ResponseScopeEnum_user =
    const PostAdminAnalyticsFunnel200ResponseScopeEnum._('user');
const PostAdminAnalyticsFunnel200ResponseScopeEnum
    _$postAdminAnalyticsFunnel200ResponseScopeEnum_session =
    const PostAdminAnalyticsFunnel200ResponseScopeEnum._('session');
const PostAdminAnalyticsFunnel200ResponseScopeEnum
    _$postAdminAnalyticsFunnel200ResponseScopeEnum_flow =
    const PostAdminAnalyticsFunnel200ResponseScopeEnum._('flow');

PostAdminAnalyticsFunnel200ResponseScopeEnum
    _$postAdminAnalyticsFunnel200ResponseScopeEnumValueOf(String name) {
  switch (name) {
    case 'user':
      return _$postAdminAnalyticsFunnel200ResponseScopeEnum_user;
    case 'session':
      return _$postAdminAnalyticsFunnel200ResponseScopeEnum_session;
    case 'flow':
      return _$postAdminAnalyticsFunnel200ResponseScopeEnum_flow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAnalyticsFunnel200ResponseScopeEnum>
    _$postAdminAnalyticsFunnel200ResponseScopeEnumValues = BuiltSet<
        PostAdminAnalyticsFunnel200ResponseScopeEnum>(const <PostAdminAnalyticsFunnel200ResponseScopeEnum>[
  _$postAdminAnalyticsFunnel200ResponseScopeEnum_user,
  _$postAdminAnalyticsFunnel200ResponseScopeEnum_session,
  _$postAdminAnalyticsFunnel200ResponseScopeEnum_flow,
]);

Serializer<PostAdminAnalyticsFunnel200ResponseScopeEnum>
    _$postAdminAnalyticsFunnel200ResponseScopeEnumSerializer =
    _$PostAdminAnalyticsFunnel200ResponseScopeEnumSerializer();

class _$PostAdminAnalyticsFunnel200ResponseScopeEnumSerializer
    implements
        PrimitiveSerializer<PostAdminAnalyticsFunnel200ResponseScopeEnum> {
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
    PostAdminAnalyticsFunnel200ResponseScopeEnum
  ];
  @override
  final String wireName = 'PostAdminAnalyticsFunnel200ResponseScopeEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAnalyticsFunnel200ResponseScopeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAnalyticsFunnel200ResponseScopeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAnalyticsFunnel200ResponseScopeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAnalyticsFunnel200Response
    extends PostAdminAnalyticsFunnel200Response {
  @override
  final PostAdminAnalyticsFunnel200ResponseRange range;
  @override
  final PostAdminAnalyticsFunnel200ResponseScopeEnum scope;
  @override
  final int windowMinutes;
  @override
  final BuiltList<PostAdminAnalyticsFunnel200ResponseStepsInner> steps;
  @override
  final num? completionRate;
  @override
  final PostAdminAnalyticsFunnel200ResponseCoverage coverage;

  factory _$PostAdminAnalyticsFunnel200Response(
          [void Function(PostAdminAnalyticsFunnel200ResponseBuilder)?
              updates]) =>
      (PostAdminAnalyticsFunnel200ResponseBuilder()..update(updates))._build();

  _$PostAdminAnalyticsFunnel200Response._(
      {required this.range,
      required this.scope,
      required this.windowMinutes,
      required this.steps,
      this.completionRate,
      required this.coverage})
      : super._();
  @override
  PostAdminAnalyticsFunnel200Response rebuild(
          void Function(PostAdminAnalyticsFunnel200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAnalyticsFunnel200ResponseBuilder toBuilder() =>
      PostAdminAnalyticsFunnel200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAnalyticsFunnel200Response &&
        range == other.range &&
        scope == other.scope &&
        windowMinutes == other.windowMinutes &&
        steps == other.steps &&
        completionRate == other.completionRate &&
        coverage == other.coverage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, range.hashCode);
    _$hash = $jc(_$hash, scope.hashCode);
    _$hash = $jc(_$hash, windowMinutes.hashCode);
    _$hash = $jc(_$hash, steps.hashCode);
    _$hash = $jc(_$hash, completionRate.hashCode);
    _$hash = $jc(_$hash, coverage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAnalyticsFunnel200Response')
          ..add('range', range)
          ..add('scope', scope)
          ..add('windowMinutes', windowMinutes)
          ..add('steps', steps)
          ..add('completionRate', completionRate)
          ..add('coverage', coverage))
        .toString();
  }
}

class PostAdminAnalyticsFunnel200ResponseBuilder
    implements
        Builder<PostAdminAnalyticsFunnel200Response,
            PostAdminAnalyticsFunnel200ResponseBuilder> {
  _$PostAdminAnalyticsFunnel200Response? _$v;

  PostAdminAnalyticsFunnel200ResponseRangeBuilder? _range;
  PostAdminAnalyticsFunnel200ResponseRangeBuilder get range =>
      _$this._range ??= PostAdminAnalyticsFunnel200ResponseRangeBuilder();
  set range(PostAdminAnalyticsFunnel200ResponseRangeBuilder? range) =>
      _$this._range = range;

  PostAdminAnalyticsFunnel200ResponseScopeEnum? _scope;
  PostAdminAnalyticsFunnel200ResponseScopeEnum? get scope => _$this._scope;
  set scope(PostAdminAnalyticsFunnel200ResponseScopeEnum? scope) =>
      _$this._scope = scope;

  int? _windowMinutes;
  int? get windowMinutes => _$this._windowMinutes;
  set windowMinutes(int? windowMinutes) =>
      _$this._windowMinutes = windowMinutes;

  ListBuilder<PostAdminAnalyticsFunnel200ResponseStepsInner>? _steps;
  ListBuilder<PostAdminAnalyticsFunnel200ResponseStepsInner> get steps =>
      _$this._steps ??=
          ListBuilder<PostAdminAnalyticsFunnel200ResponseStepsInner>();
  set steps(
          ListBuilder<PostAdminAnalyticsFunnel200ResponseStepsInner>? steps) =>
      _$this._steps = steps;

  num? _completionRate;
  num? get completionRate => _$this._completionRate;
  set completionRate(num? completionRate) =>
      _$this._completionRate = completionRate;

  PostAdminAnalyticsFunnel200ResponseCoverageBuilder? _coverage;
  PostAdminAnalyticsFunnel200ResponseCoverageBuilder get coverage =>
      _$this._coverage ??= PostAdminAnalyticsFunnel200ResponseCoverageBuilder();
  set coverage(PostAdminAnalyticsFunnel200ResponseCoverageBuilder? coverage) =>
      _$this._coverage = coverage;

  PostAdminAnalyticsFunnel200ResponseBuilder() {
    PostAdminAnalyticsFunnel200Response._defaults(this);
  }

  PostAdminAnalyticsFunnel200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _range = $v.range.toBuilder();
      _scope = $v.scope;
      _windowMinutes = $v.windowMinutes;
      _steps = $v.steps.toBuilder();
      _completionRate = $v.completionRate;
      _coverage = $v.coverage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAnalyticsFunnel200Response other) {
    _$v = other as _$PostAdminAnalyticsFunnel200Response;
  }

  @override
  void update(
      void Function(PostAdminAnalyticsFunnel200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAnalyticsFunnel200Response build() => _build();

  _$PostAdminAnalyticsFunnel200Response _build() {
    _$PostAdminAnalyticsFunnel200Response _$result;
    try {
      _$result = _$v ??
          _$PostAdminAnalyticsFunnel200Response._(
            range: range.build(),
            scope: BuiltValueNullFieldError.checkNotNull(
                scope, r'PostAdminAnalyticsFunnel200Response', 'scope'),
            windowMinutes: BuiltValueNullFieldError.checkNotNull(windowMinutes,
                r'PostAdminAnalyticsFunnel200Response', 'windowMinutes'),
            steps: steps.build(),
            completionRate: completionRate,
            coverage: coverage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'range';
        range.build();

        _$failedField = 'steps';
        steps.build();

        _$failedField = 'coverage';
        coverage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'PostAdminAnalyticsFunnel200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
