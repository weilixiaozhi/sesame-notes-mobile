// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_profile_me200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetProfileMe200ResponseGenderEnum
    _$getProfileMe200ResponseGenderEnum_UNSPECIFIED =
    const GetProfileMe200ResponseGenderEnum._('UNSPECIFIED');
const GetProfileMe200ResponseGenderEnum
    _$getProfileMe200ResponseGenderEnum_MALE =
    const GetProfileMe200ResponseGenderEnum._('MALE');
const GetProfileMe200ResponseGenderEnum
    _$getProfileMe200ResponseGenderEnum_FEMALE =
    const GetProfileMe200ResponseGenderEnum._('FEMALE');

GetProfileMe200ResponseGenderEnum _$getProfileMe200ResponseGenderEnumValueOf(
    String name) {
  switch (name) {
    case 'UNSPECIFIED':
      return _$getProfileMe200ResponseGenderEnum_UNSPECIFIED;
    case 'MALE':
      return _$getProfileMe200ResponseGenderEnum_MALE;
    case 'FEMALE':
      return _$getProfileMe200ResponseGenderEnum_FEMALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetProfileMe200ResponseGenderEnum>
    _$getProfileMe200ResponseGenderEnumValues = BuiltSet<
        GetProfileMe200ResponseGenderEnum>(const <GetProfileMe200ResponseGenderEnum>[
  _$getProfileMe200ResponseGenderEnum_UNSPECIFIED,
  _$getProfileMe200ResponseGenderEnum_MALE,
  _$getProfileMe200ResponseGenderEnum_FEMALE,
]);

Serializer<GetProfileMe200ResponseGenderEnum>
    _$getProfileMe200ResponseGenderEnumSerializer =
    _$GetProfileMe200ResponseGenderEnumSerializer();

class _$GetProfileMe200ResponseGenderEnumSerializer
    implements PrimitiveSerializer<GetProfileMe200ResponseGenderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'UNSPECIFIED': 'UNSPECIFIED',
    'MALE': 'MALE',
    'FEMALE': 'FEMALE',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'UNSPECIFIED': 'UNSPECIFIED',
    'MALE': 'MALE',
    'FEMALE': 'FEMALE',
  };

  @override
  final Iterable<Type> types = const <Type>[GetProfileMe200ResponseGenderEnum];
  @override
  final String wireName = 'GetProfileMe200ResponseGenderEnum';

  @override
  Object serialize(
          Serializers serializers, GetProfileMe200ResponseGenderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetProfileMe200ResponseGenderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetProfileMe200ResponseGenderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetProfileMe200Response extends GetProfileMe200Response {
  @override
  final String userId;
  @override
  final String? sesameNumber;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final String phone;
  @override
  final String? phoneMasked;
  @override
  final GetProfileMe200ResponseGenderEnum gender;
  @override
  final bool isAdmin;
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

  factory _$GetProfileMe200Response(
          [void Function(GetProfileMe200ResponseBuilder)? updates]) =>
      (GetProfileMe200ResponseBuilder()..update(updates))._build();

  _$GetProfileMe200Response._(
      {required this.userId,
      this.sesameNumber,
      this.displayName,
      this.avatarUrl,
      required this.avatarVersion,
      required this.phone,
      this.phoneMasked,
      required this.gender,
      required this.isAdmin,
      this.incomeIsRed,
      this.themePrimaryColor,
      this.appearance,
      this.aiConfig,
      this.primaryCurrency})
      : super._();
  @override
  GetProfileMe200Response rebuild(
          void Function(GetProfileMe200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetProfileMe200ResponseBuilder toBuilder() =>
      GetProfileMe200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetProfileMe200Response &&
        userId == other.userId &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        phone == other.phone &&
        phoneMasked == other.phoneMasked &&
        gender == other.gender &&
        isAdmin == other.isAdmin &&
        incomeIsRed == other.incomeIsRed &&
        themePrimaryColor == other.themePrimaryColor &&
        appearance == other.appearance &&
        aiConfig == other.aiConfig &&
        primaryCurrency == other.primaryCurrency;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, isAdmin.hashCode);
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
    return (newBuiltValueToStringHelper(r'GetProfileMe200Response')
          ..add('userId', userId)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('phone', phone)
          ..add('phoneMasked', phoneMasked)
          ..add('gender', gender)
          ..add('isAdmin', isAdmin)
          ..add('incomeIsRed', incomeIsRed)
          ..add('themePrimaryColor', themePrimaryColor)
          ..add('appearance', appearance)
          ..add('aiConfig', aiConfig)
          ..add('primaryCurrency', primaryCurrency))
        .toString();
  }
}

class GetProfileMe200ResponseBuilder
    implements
        Builder<GetProfileMe200Response, GetProfileMe200ResponseBuilder> {
  _$GetProfileMe200Response? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _sesameNumber;
  String? get sesameNumber => _$this._sesameNumber;
  set sesameNumber(String? sesameNumber) => _$this._sesameNumber = sesameNumber;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  GetProfileMe200ResponseGenderEnum? _gender;
  GetProfileMe200ResponseGenderEnum? get gender => _$this._gender;
  set gender(GetProfileMe200ResponseGenderEnum? gender) =>
      _$this._gender = gender;

  bool? _isAdmin;
  bool? get isAdmin => _$this._isAdmin;
  set isAdmin(bool? isAdmin) => _$this._isAdmin = isAdmin;

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

  GetProfileMe200ResponseBuilder() {
    GetProfileMe200Response._defaults(this);
  }

  GetProfileMe200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _sesameNumber = $v.sesameNumber;
      _displayName = $v.displayName;
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _phone = $v.phone;
      _phoneMasked = $v.phoneMasked;
      _gender = $v.gender;
      _isAdmin = $v.isAdmin;
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
  void replace(GetProfileMe200Response other) {
    _$v = other as _$GetProfileMe200Response;
  }

  @override
  void update(void Function(GetProfileMe200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetProfileMe200Response build() => _build();

  _$GetProfileMe200Response _build() {
    _$GetProfileMe200Response _$result;
    try {
      _$result = _$v ??
          _$GetProfileMe200Response._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'GetProfileMe200Response', 'userId'),
            sesameNumber: sesameNumber,
            displayName: displayName,
            avatarUrl: avatarUrl,
            avatarVersion: BuiltValueNullFieldError.checkNotNull(
                avatarVersion, r'GetProfileMe200Response', 'avatarVersion'),
            phone: BuiltValueNullFieldError.checkNotNull(
                phone, r'GetProfileMe200Response', 'phone'),
            phoneMasked: phoneMasked,
            gender: BuiltValueNullFieldError.checkNotNull(
                gender, r'GetProfileMe200Response', 'gender'),
            isAdmin: BuiltValueNullFieldError.checkNotNull(
                isAdmin, r'GetProfileMe200Response', 'isAdmin'),
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
            r'GetProfileMe200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
