// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users_by_user_id200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminUsersByUserId200ResponseGenderEnum
    _$getAdminUsersByUserId200ResponseGenderEnum_UNSPECIFIED =
    const GetAdminUsersByUserId200ResponseGenderEnum._('UNSPECIFIED');
const GetAdminUsersByUserId200ResponseGenderEnum
    _$getAdminUsersByUserId200ResponseGenderEnum_MALE =
    const GetAdminUsersByUserId200ResponseGenderEnum._('MALE');
const GetAdminUsersByUserId200ResponseGenderEnum
    _$getAdminUsersByUserId200ResponseGenderEnum_FEMALE =
    const GetAdminUsersByUserId200ResponseGenderEnum._('FEMALE');

GetAdminUsersByUserId200ResponseGenderEnum
    _$getAdminUsersByUserId200ResponseGenderEnumValueOf(String name) {
  switch (name) {
    case 'UNSPECIFIED':
      return _$getAdminUsersByUserId200ResponseGenderEnum_UNSPECIFIED;
    case 'MALE':
      return _$getAdminUsersByUserId200ResponseGenderEnum_MALE;
    case 'FEMALE':
      return _$getAdminUsersByUserId200ResponseGenderEnum_FEMALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminUsersByUserId200ResponseGenderEnum>
    _$getAdminUsersByUserId200ResponseGenderEnumValues = BuiltSet<
        GetAdminUsersByUserId200ResponseGenderEnum>(const <GetAdminUsersByUserId200ResponseGenderEnum>[
  _$getAdminUsersByUserId200ResponseGenderEnum_UNSPECIFIED,
  _$getAdminUsersByUserId200ResponseGenderEnum_MALE,
  _$getAdminUsersByUserId200ResponseGenderEnum_FEMALE,
]);

Serializer<GetAdminUsersByUserId200ResponseGenderEnum>
    _$getAdminUsersByUserId200ResponseGenderEnumSerializer =
    _$GetAdminUsersByUserId200ResponseGenderEnumSerializer();

class _$GetAdminUsersByUserId200ResponseGenderEnumSerializer
    implements PrimitiveSerializer<GetAdminUsersByUserId200ResponseGenderEnum> {
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
  final Iterable<Type> types = const <Type>[
    GetAdminUsersByUserId200ResponseGenderEnum
  ];
  @override
  final String wireName = 'GetAdminUsersByUserId200ResponseGenderEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminUsersByUserId200ResponseGenderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminUsersByUserId200ResponseGenderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminUsersByUserId200ResponseGenderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminUsersByUserId200Response
    extends GetAdminUsersByUserId200Response {
  @override
  final String id;
  @override
  final String phone;
  @override
  final String? phoneMasked;
  @override
  final String? sesameNumber;
  @override
  final String? displayName;
  @override
  final GetAdminUsersByUserId200ResponseGenderEnum gender;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final bool isEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime? profileUpdatedAt;
  @override
  final String? primaryCurrency;
  @override
  final String? themePrimaryColor;

  factory _$GetAdminUsersByUserId200Response(
          [void Function(GetAdminUsersByUserId200ResponseBuilder)? updates]) =>
      (GetAdminUsersByUserId200ResponseBuilder()..update(updates))._build();

  _$GetAdminUsersByUserId200Response._(
      {required this.id,
      required this.phone,
      this.phoneMasked,
      this.sesameNumber,
      this.displayName,
      required this.gender,
      this.avatarUrl,
      required this.avatarVersion,
      required this.isEnabled,
      required this.createdAt,
      this.profileUpdatedAt,
      this.primaryCurrency,
      this.themePrimaryColor})
      : super._();
  @override
  GetAdminUsersByUserId200Response rebuild(
          void Function(GetAdminUsersByUserId200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsersByUserId200ResponseBuilder toBuilder() =>
      GetAdminUsersByUserId200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsersByUserId200Response &&
        id == other.id &&
        phone == other.phone &&
        phoneMasked == other.phoneMasked &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        gender == other.gender &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        isEnabled == other.isEnabled &&
        createdAt == other.createdAt &&
        profileUpdatedAt == other.profileUpdatedAt &&
        primaryCurrency == other.primaryCurrency &&
        themePrimaryColor == other.themePrimaryColor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, profileUpdatedAt.hashCode);
    _$hash = $jc(_$hash, primaryCurrency.hashCode);
    _$hash = $jc(_$hash, themePrimaryColor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminUsersByUserId200Response')
          ..add('id', id)
          ..add('phone', phone)
          ..add('phoneMasked', phoneMasked)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('gender', gender)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('isEnabled', isEnabled)
          ..add('createdAt', createdAt)
          ..add('profileUpdatedAt', profileUpdatedAt)
          ..add('primaryCurrency', primaryCurrency)
          ..add('themePrimaryColor', themePrimaryColor))
        .toString();
  }
}

class GetAdminUsersByUserId200ResponseBuilder
    implements
        Builder<GetAdminUsersByUserId200Response,
            GetAdminUsersByUserId200ResponseBuilder> {
  _$GetAdminUsersByUserId200Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  String? _sesameNumber;
  String? get sesameNumber => _$this._sesameNumber;
  set sesameNumber(String? sesameNumber) => _$this._sesameNumber = sesameNumber;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  GetAdminUsersByUserId200ResponseGenderEnum? _gender;
  GetAdminUsersByUserId200ResponseGenderEnum? get gender => _$this._gender;
  set gender(GetAdminUsersByUserId200ResponseGenderEnum? gender) =>
      _$this._gender = gender;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _profileUpdatedAt;
  DateTime? get profileUpdatedAt => _$this._profileUpdatedAt;
  set profileUpdatedAt(DateTime? profileUpdatedAt) =>
      _$this._profileUpdatedAt = profileUpdatedAt;

  String? _primaryCurrency;
  String? get primaryCurrency => _$this._primaryCurrency;
  set primaryCurrency(String? primaryCurrency) =>
      _$this._primaryCurrency = primaryCurrency;

  String? _themePrimaryColor;
  String? get themePrimaryColor => _$this._themePrimaryColor;
  set themePrimaryColor(String? themePrimaryColor) =>
      _$this._themePrimaryColor = themePrimaryColor;

  GetAdminUsersByUserId200ResponseBuilder() {
    GetAdminUsersByUserId200Response._defaults(this);
  }

  GetAdminUsersByUserId200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _phone = $v.phone;
      _phoneMasked = $v.phoneMasked;
      _sesameNumber = $v.sesameNumber;
      _displayName = $v.displayName;
      _gender = $v.gender;
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _isEnabled = $v.isEnabled;
      _createdAt = $v.createdAt;
      _profileUpdatedAt = $v.profileUpdatedAt;
      _primaryCurrency = $v.primaryCurrency;
      _themePrimaryColor = $v.themePrimaryColor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminUsersByUserId200Response other) {
    _$v = other as _$GetAdminUsersByUserId200Response;
  }

  @override
  void update(void Function(GetAdminUsersByUserId200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsersByUserId200Response build() => _build();

  _$GetAdminUsersByUserId200Response _build() {
    final _$result = _$v ??
        _$GetAdminUsersByUserId200Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminUsersByUserId200Response', 'id'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'GetAdminUsersByUserId200Response', 'phone'),
          phoneMasked: phoneMasked,
          sesameNumber: sesameNumber,
          displayName: displayName,
          gender: BuiltValueNullFieldError.checkNotNull(
              gender, r'GetAdminUsersByUserId200Response', 'gender'),
          avatarUrl: avatarUrl,
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'GetAdminUsersByUserId200Response', 'avatarVersion'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(
              isEnabled, r'GetAdminUsersByUserId200Response', 'isEnabled'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'GetAdminUsersByUserId200Response', 'createdAt'),
          profileUpdatedAt: profileUpdatedAt,
          primaryCurrency: primaryCurrency,
          themePrimaryColor: themePrimaryColor,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
