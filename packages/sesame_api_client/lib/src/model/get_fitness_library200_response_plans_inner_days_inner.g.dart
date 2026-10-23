// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response_plans_inner_days_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessLibrary200ResponsePlansInnerDaysInner
    extends GetFitnessLibrary200ResponsePlansInnerDaysInner {
  @override
  final int dayIndex;
  @override
  final String? templateId;

  factory _$GetFitnessLibrary200ResponsePlansInnerDaysInner(
          [void Function(
                  GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder)?
              updates]) =>
      (GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessLibrary200ResponsePlansInnerDaysInner._(
      {required this.dayIndex, this.templateId})
      : super._();
  @override
  GetFitnessLibrary200ResponsePlansInnerDaysInner rebuild(
          void Function(GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder toBuilder() =>
      GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200ResponsePlansInnerDaysInner &&
        dayIndex == other.dayIndex &&
        templateId == other.templateId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dayIndex.hashCode);
    _$hash = $jc(_$hash, templateId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessLibrary200ResponsePlansInnerDaysInner')
          ..add('dayIndex', dayIndex)
          ..add('templateId', templateId))
        .toString();
  }
}

class GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder
    implements
        Builder<GetFitnessLibrary200ResponsePlansInnerDaysInner,
            GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder> {
  _$GetFitnessLibrary200ResponsePlansInnerDaysInner? _$v;

  int? _dayIndex;
  int? get dayIndex => _$this._dayIndex;
  set dayIndex(int? dayIndex) => _$this._dayIndex = dayIndex;

  String? _templateId;
  String? get templateId => _$this._templateId;
  set templateId(String? templateId) => _$this._templateId = templateId;

  GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder() {
    GetFitnessLibrary200ResponsePlansInnerDaysInner._defaults(this);
  }

  GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dayIndex = $v.dayIndex;
      _templateId = $v.templateId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200ResponsePlansInnerDaysInner other) {
    _$v = other as _$GetFitnessLibrary200ResponsePlansInnerDaysInner;
  }

  @override
  void update(
      void Function(GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200ResponsePlansInnerDaysInner build() => _build();

  _$GetFitnessLibrary200ResponsePlansInnerDaysInner _build() {
    final _$result = _$v ??
        _$GetFitnessLibrary200ResponsePlansInnerDaysInner._(
          dayIndex: BuiltValueNullFieldError.checkNotNull(dayIndex,
              r'GetFitnessLibrary200ResponsePlansInnerDaysInner', 'dayIndex'),
          templateId: templateId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
