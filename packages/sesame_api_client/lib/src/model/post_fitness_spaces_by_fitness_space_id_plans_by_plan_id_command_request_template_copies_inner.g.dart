// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
    extends PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner {
  @override
  final String id;
  @override
  final PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      payload;

  factory _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner._(
      {required this.id, required this.payload})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
      rebuild(
              void Function(
                      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
      toBuilder() =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner &&
        id == other.id &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner')
          ..add('id', id)
          ..add('payload', payload))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
    implements
        Builder<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder?
      _payload;
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
      get payload => _$this._payload ??=
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder();
  set payload(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder?
              payload) =>
      _$this._payload = payload;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder() {
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
        ._defaults(this);
  }

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
          other) {
    _$v = other
        as _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner;
  }

  @override
  void update(
      void Function(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
      build() => _build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
      _build() {
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
        _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner',
                'id'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner',
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
