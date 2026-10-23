// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response
    extends PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response {
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner plan;
  @override
  final int generatedCount;
  @override
  final int removedCount;
  @override
  final bool hasMore;
  @override
  final bool replayed;

  factory _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response._(
      {required this.plan,
      required this.generatedCount,
      required this.removedCount,
      required this.hasMore,
      required this.replayed})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response rebuild(
          void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
      toBuilder() =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response &&
        plan == other.plan &&
        generatedCount == other.generatedCount &&
        removedCount == other.removedCount &&
        hasMore == other.hasMore &&
        replayed == other.replayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, generatedCount.hashCode);
    _$hash = $jc(_$hash, removedCount.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, replayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response')
          ..add('plan', plan)
          ..add('generatedCount', generatedCount)
          ..add('removedCount', removedCount)
          ..add('hasMore', hasMore)
          ..add('replayed', replayed))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
    implements
        Builder<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response? _$v;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder? _plan;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder get plan =>
      _$this._plan ??=
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder();
  set plan(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder?
              plan) =>
      _$this._plan = plan;

  int? _generatedCount;
  int? get generatedCount => _$this._generatedCount;
  set generatedCount(int? generatedCount) =>
      _$this._generatedCount = generatedCount;

  int? _removedCount;
  int? get removedCount => _$this._removedCount;
  set removedCount(int? removedCount) => _$this._removedCount = removedCount;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  bool? _replayed;
  bool? get replayed => _$this._replayed;
  set replayed(bool? replayed) => _$this._replayed = replayed;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder() {
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response._defaults(
        this);
  }

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _plan = $v.plan.toBuilder();
      _generatedCount = $v.generatedCount;
      _removedCount = $v.removedCount;
      _hasMore = $v.hasMore;
      _replayed = $v.replayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response other) {
    _$v = other
        as _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response;
  }

  @override
  void update(
      void Function(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response build() =>
      _build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response _build() {
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response._(
            plan: plan.build(),
            generatedCount: BuiltValueNullFieldError.checkNotNull(
                generatedCount,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response',
                'generatedCount'),
            removedCount: BuiltValueNullFieldError.checkNotNull(
                removedCount,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response',
                'removedCount'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response',
                'hasMore'),
            replayed: BuiltValueNullFieldError.checkNotNull(
                replayed,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response',
                'replayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plan';
        plan.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response',
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
