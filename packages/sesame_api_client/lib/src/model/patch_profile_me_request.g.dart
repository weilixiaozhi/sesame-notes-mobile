// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_profile_me_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchProfileMeRequest extends PatchProfileMeRequest {
  @override
  final String? displayName;
  @override
  final String? gender;
  @override
  final bool? incomeIsRed;
  @override
  final String? themePrimaryColor;
  @override
  final BuiltMap<String, JsonObject?>? appearance;
  @override
  final BuiltMap<String, JsonObject?>? aiConfig;
  @override
  final String? primaryCurrency;

  factory _$PatchProfileMeRequest(
          [void Function(PatchProfileMeRequestBuilder)? updates]) =>
      (PatchProfileMeRequestBuilder()..update(updates))._build();

  _$PatchProfileMeRequest._(
      {this.displayName,
      this.gender,
      this.incomeIsRed,
      this.themePrimaryColor,
      this.appearance,
      this.aiConfig,
      this.primaryCurrency})
      : super._();
  @override
  PatchProfileMeRequest rebuild(
          void Function(PatchProfileMeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchProfileMeRequestBuilder toBuilder() =>
      PatchProfileMeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchProfileMeRequest &&
        displayName == other.displayName &&
        gender == other.gender &&
        incomeIsRed == other.incomeIsRed &&
        themePrimaryColor == other.themePrimaryColor &&
        appearance == other.appearance &&
        aiConfig == other.aiConfig &&
        primaryCurrency == other.primaryCurrency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, incomeIsRed.hashCode);
    _$hash = $jc(_$hash, themePrimaryColor.hashCode);
    _$hash = $jc(_$hash, appearance.hashCode);
    _$hash = $jc(_$hash, aiConfig.hashCode);
    _$hash = $jc(_$hash, primaryCurrency.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatchProfileMeRequest')
          ..add('displayName', displayName)
          ..add('gender', gender)
          ..add('incomeIsRed', incomeIsRed)
          ..add('themePrimaryColor', themePrimaryColor)
          ..add('appearance', appearance)
          ..add('aiConfig', aiConfig)
          ..add('primaryCurrency', primaryCurrency))
        .toString();
  }
}

class PatchProfileMeRequestBuilder
    implements Builder<PatchProfileMeRequest, PatchProfileMeRequestBuilder> {
  _$PatchProfileMeRequest? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _gender;
  String? get gender => _$this._gender;
  set gender(String? gender) => _$this._gender = gender;

  bool? _incomeIsRed;
  bool? get incomeIsRed => _$this._incomeIsRed;
  set incomeIsRed(bool? incomeIsRed) => _$this._incomeIsRed = incomeIsRed;

  String? _themePrimaryColor;
  String? get themePrimaryColor => _$this._themePrimaryColor;
  set themePrimaryColor(String? themePrimaryColor) =>
      _$this._themePrimaryColor = themePrimaryColor;

  MapBuilder<String, JsonObject?>? _appearance;
  MapBuilder<String, JsonObject?> get appearance =>
      _$this._appearance ??= MapBuilder<String, JsonObject?>();
  set appearance(MapBuilder<String, JsonObject?>? appearance) =>
      _$this._appearance = appearance;

  MapBuilder<String, JsonObject?>? _aiConfig;
  MapBuilder<String, JsonObject?> get aiConfig =>
      _$this._aiConfig ??= MapBuilder<String, JsonObject?>();
  set aiConfig(MapBuilder<String, JsonObject?>? aiConfig) =>
      _$this._aiConfig = aiConfig;

  String? _primaryCurrency;
  String? get primaryCurrency => _$this._primaryCurrency;
  set primaryCurrency(String? primaryCurrency) =>
      _$this._primaryCurrency = primaryCurrency;

  PatchProfileMeRequestBuilder() {
    PatchProfileMeRequest._defaults(this);
  }

  PatchProfileMeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _gender = $v.gender;
      _incomeIsRed = $v.incomeIsRed;
      _themePrimaryColor = $v.themePrimaryColor;
      _appearance = $v.appearance?.toBuilder();
      _aiConfig = $v.aiConfig?.toBuilder();
      _primaryCurrency = $v.primaryCurrency;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchProfileMeRequest other) {
    _$v = other as _$PatchProfileMeRequest;
  }

  @override
  void update(void Function(PatchProfileMeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchProfileMeRequest build() => _build();

  _$PatchProfileMeRequest _build() {
    _$PatchProfileMeRequest _$result;
    try {
      _$result = _$v ??
          _$PatchProfileMeRequest._(
            displayName: displayName,
            gender: gender,
            incomeIsRed: incomeIsRed,
            themePrimaryColor: themePrimaryColor,
            appearance: _appearance?.build(),
            aiConfig: _aiConfig?.build(),
            primaryCurrency: primaryCurrency,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'appearance';
        _appearance?.build();
        _$failedField = 'aiConfig';
        _aiConfig?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatchProfileMeRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
