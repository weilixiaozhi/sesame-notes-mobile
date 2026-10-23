// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_run_segments_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner {
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner._(
      {required this.startedAt, this.endedAt})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner')
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner?
      _$v;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
            ._(
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt,
              r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner',
              'startedAt'),
          endedAt: endedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
