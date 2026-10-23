// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response_templates_inner_goals.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessLibrary200ResponseTemplatesInnerGoals
    extends GetFitnessLibrary200ResponseTemplatesInnerGoals {
  @override
  final BuiltList<String> zh;
  @override
  final BuiltList<String> zhHant;
  @override
  final BuiltList<String> en;

  factory _$GetFitnessLibrary200ResponseTemplatesInnerGoals(
          [void Function(
                  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder)?
              updates]) =>
      (GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessLibrary200ResponseTemplatesInnerGoals._(
      {required this.zh, required this.zhHant, required this.en})
      : super._();
  @override
  GetFitnessLibrary200ResponseTemplatesInnerGoals rebuild(
          void Function(GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder toBuilder() =>
      GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200ResponseTemplatesInnerGoals &&
        zh == other.zh &&
        zhHant == other.zhHant &&
        en == other.en;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, zh.hashCode);
    _$hash = $jc(_$hash, zhHant.hashCode);
    _$hash = $jc(_$hash, en.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessLibrary200ResponseTemplatesInnerGoals')
          ..add('zh', zh)
          ..add('zhHant', zhHant)
          ..add('en', en))
        .toString();
  }
}

class GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder
    implements
        Builder<GetFitnessLibrary200ResponseTemplatesInnerGoals,
            GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder> {
  _$GetFitnessLibrary200ResponseTemplatesInnerGoals? _$v;

  ListBuilder<String>? _zh;
  ListBuilder<String> get zh => _$this._zh ??= ListBuilder<String>();
  set zh(ListBuilder<String>? zh) => _$this._zh = zh;

  ListBuilder<String>? _zhHant;
  ListBuilder<String> get zhHant => _$this._zhHant ??= ListBuilder<String>();
  set zhHant(ListBuilder<String>? zhHant) => _$this._zhHant = zhHant;

  ListBuilder<String>? _en;
  ListBuilder<String> get en => _$this._en ??= ListBuilder<String>();
  set en(ListBuilder<String>? en) => _$this._en = en;

  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder() {
    GetFitnessLibrary200ResponseTemplatesInnerGoals._defaults(this);
  }

  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _zh = $v.zh.toBuilder();
      _zhHant = $v.zhHant.toBuilder();
      _en = $v.en.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200ResponseTemplatesInnerGoals other) {
    _$v = other as _$GetFitnessLibrary200ResponseTemplatesInnerGoals;
  }

  @override
  void update(
      void Function(GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInnerGoals build() => _build();

  _$GetFitnessLibrary200ResponseTemplatesInnerGoals _build() {
    _$GetFitnessLibrary200ResponseTemplatesInnerGoals _$result;
    try {
      _$result = _$v ??
          _$GetFitnessLibrary200ResponseTemplatesInnerGoals._(
            zh: zh.build(),
            zhHant: zhHant.build(),
            en: en.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'zh';
        zh.build();
        _$failedField = 'zhHant';
        zhHant.build();
        _$failedField = 'en';
        en.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessLibrary200ResponseTemplatesInnerGoals',
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
