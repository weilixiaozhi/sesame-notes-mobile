// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_save =
    const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
        ._('save');
const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_generate =
    const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
        ._('generate');

PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumValueOf(
        String name) {
  switch (name) {
    case 'save':
      return _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_save;
    case 'generate':
      return _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_generate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumValues =
    BuiltSet<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>(const <PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>[
  _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_save,
  _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_generate,
]);

Serializer<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumSerializer =
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumSerializer();

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'save': 'save',
    'generate': 'generate',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'save': 'save',
    'generate': 'generate',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
  ];
  @override
  final String wireName =
      'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
    extends PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest {
  @override
  final String mutationId;
  @override
  final String syncId;
  @override
  final int baseRevision;
  @override
  final String today;
  @override
  final PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      action;
  @override
  final PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan? plan;
  @override
  final String? restartDate;
  @override
  final BuiltList<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>?
      templateCopies;

  factory _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest._(
      {required this.mutationId,
      required this.syncId,
      required this.baseRevision,
      required this.today,
      required this.action,
      this.plan,
      this.restartDate,
      this.templateCopies})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest rebuild(
          void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
      toBuilder() =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest &&
        mutationId == other.mutationId &&
        syncId == other.syncId &&
        baseRevision == other.baseRevision &&
        today == other.today &&
        action == other.action &&
        plan == other.plan &&
        restartDate == other.restartDate &&
        templateCopies == other.templateCopies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jc(_$hash, today.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, restartDate.hashCode);
    _$hash = $jc(_$hash, templateCopies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest')
          ..add('mutationId', mutationId)
          ..add('syncId', syncId)
          ..add('baseRevision', baseRevision)
          ..add('today', today)
          ..add('action', action)
          ..add('plan', plan)
          ..add('restartDate', restartDate)
          ..add('templateCopies', templateCopies))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
    implements
        Builder<PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  String? _today;
  String? get today => _$this._today;
  set today(String? today) => _$this._today = today;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum?
      _action;
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum?
      get action => _$this._action;
  set action(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum?
              action) =>
      _$this._action = action;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder?
      _plan;
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder
      get plan => _$this._plan ??=
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder();
  set plan(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder?
              plan) =>
      _$this._plan = plan;

  String? _restartDate;
  String? get restartDate => _$this._restartDate;
  set restartDate(String? restartDate) => _$this._restartDate = restartDate;

  ListBuilder<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>?
      _templateCopies;
  ListBuilder<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>
      get templateCopies => _$this._templateCopies ??= ListBuilder<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>();
  set templateCopies(
          ListBuilder<
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>?
              templateCopies) =>
      _$this._templateCopies = templateCopies;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder() {
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest._defaults(
        this);
  }

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _syncId = $v.syncId;
      _baseRevision = $v.baseRevision;
      _today = $v.today;
      _action = $v.action;
      _plan = $v.plan?.toBuilder();
      _restartDate = $v.restartDate;
      _templateCopies = $v.templateCopies?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest other) {
    _$v =
        other as _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest;
  }

  @override
  void update(
      void Function(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest build() =>
      _build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest _build() {
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest._(
            mutationId: BuiltValueNullFieldError.checkNotNull(
                mutationId,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
                'mutationId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
                'syncId'),
            baseRevision: BuiltValueNullFieldError.checkNotNull(
                baseRevision,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
                'baseRevision'),
            today: BuiltValueNullFieldError.checkNotNull(
                today,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
                'today'),
            action: BuiltValueNullFieldError.checkNotNull(
                action,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
                'action'),
            plan: _plan?.build(),
            restartDate: restartDate,
            templateCopies: _templateCopies?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plan';
        _plan?.build();

        _$failedField = 'templateCopies';
        _templateCopies?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest',
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
