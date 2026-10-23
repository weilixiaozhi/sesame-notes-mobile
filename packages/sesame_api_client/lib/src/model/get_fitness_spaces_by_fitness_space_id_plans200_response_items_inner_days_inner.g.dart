// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner {
  @override
  final int dayIndex;
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot?
      slot;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner._(
      {required this.dayIndex, this.slot})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner &&
        dayIndex == other.dayIndex &&
        slot == other.slot;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dayIndex.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner')
          ..add('dayIndex', dayIndex)
          ..add('slot', slot))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner? _$v;

  int? _dayIndex;
  int? get dayIndex => _$this._dayIndex;
  set dayIndex(int? dayIndex) => _$this._dayIndex = dayIndex;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder?
      _slot;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder
      get slot => _$this._slot ??=
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder();
  set slot(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder?
              slot) =>
      _$this._slot = slot;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _dayIndex = $v.dayIndex;
      _slot = $v.slot?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
              ._(
            dayIndex: BuiltValueNullFieldError.checkNotNull(
                dayIndex,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner',
                'dayIndex'),
            slot: _slot?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'slot';
        _slot?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner',
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
