// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminUsers200ResponseItemsInnerGenderEnum
    _$getAdminUsers200ResponseItemsInnerGenderEnum_UNSPECIFIED =
    const GetAdminUsers200ResponseItemsInnerGenderEnum._('UNSPECIFIED');
const GetAdminUsers200ResponseItemsInnerGenderEnum
    _$getAdminUsers200ResponseItemsInnerGenderEnum_MALE =
    const GetAdminUsers200ResponseItemsInnerGenderEnum._('MALE');
const GetAdminUsers200ResponseItemsInnerGenderEnum
    _$getAdminUsers200ResponseItemsInnerGenderEnum_FEMALE =
    const GetAdminUsers200ResponseItemsInnerGenderEnum._('FEMALE');

GetAdminUsers200ResponseItemsInnerGenderEnum
    _$getAdminUsers200ResponseItemsInnerGenderEnumValueOf(String name) {
  switch (name) {
    case 'UNSPECIFIED':
      return _$getAdminUsers200ResponseItemsInnerGenderEnum_UNSPECIFIED;
    case 'MALE':
      return _$getAdminUsers200ResponseItemsInnerGenderEnum_MALE;
    case 'FEMALE':
      return _$getAdminUsers200ResponseItemsInnerGenderEnum_FEMALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminUsers200ResponseItemsInnerGenderEnum>
    _$getAdminUsers200ResponseItemsInnerGenderEnumValues = BuiltSet<
        GetAdminUsers200ResponseItemsInnerGenderEnum>(const <GetAdminUsers200ResponseItemsInnerGenderEnum>[
  _$getAdminUsers200ResponseItemsInnerGenderEnum_UNSPECIFIED,
  _$getAdminUsers200ResponseItemsInnerGenderEnum_MALE,
  _$getAdminUsers200ResponseItemsInnerGenderEnum_FEMALE,
]);

Serializer<GetAdminUsers200ResponseItemsInnerGenderEnum>
    _$getAdminUsers200ResponseItemsInnerGenderEnumSerializer =
    _$GetAdminUsers200ResponseItemsInnerGenderEnumSerializer();

class _$GetAdminUsers200ResponseItemsInnerGenderEnumSerializer
    implements
        PrimitiveSerializer<GetAdminUsers200ResponseItemsInnerGenderEnum> {
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
    GetAdminUsers200ResponseItemsInnerGenderEnum
  ];
  @override
  final String wireName = 'GetAdminUsers200ResponseItemsInnerGenderEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminUsers200ResponseItemsInnerGenderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminUsers200ResponseItemsInnerGenderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminUsers200ResponseItemsInnerGenderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminUsers200ResponseItemsInner
    extends GetAdminUsers200ResponseItemsInner {
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
  final GetAdminUsers200ResponseItemsInnerGenderEnum gender;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final bool isEnabled;
  @override
  final DateTime createdAt;

  factory _$GetAdminUsers200ResponseItemsInner(
          [void Function(GetAdminUsers200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminUsers200ResponseItemsInnerBuilder()..update(updates))._build();

  _$GetAdminUsers200ResponseItemsInner._(
      {required this.id,
      required this.phone,
      this.phoneMasked,
      this.sesameNumber,
      this.displayName,
      required this.gender,
      this.avatarUrl,
      required this.avatarVersion,
      required this.isEnabled,
      required this.createdAt})
      : super._();
  @override
  GetAdminUsers200ResponseItemsInner rebuild(
          void Function(GetAdminUsers200ResponseItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsers200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminUsers200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsers200ResponseItemsInner &&
        id == other.id &&
        phone == other.phone &&
        phoneMasked == other.phoneMasked &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        gender == other.gender &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        isEnabled == other.isEnabled &&
        createdAt == other.createdAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminUsers200ResponseItemsInner')
          ..add('id', id)
          ..add('phone', phone)
          ..add('phoneMasked', phoneMasked)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('gender', gender)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('isEnabled', isEnabled)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GetAdminUsers200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminUsers200ResponseItemsInner,
            GetAdminUsers200ResponseItemsInnerBuilder> {
  _$GetAdminUsers200ResponseItemsInner? _$v;

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

  GetAdminUsers200ResponseItemsInnerGenderEnum? _gender;
  GetAdminUsers200ResponseItemsInnerGenderEnum? get gender => _$this._gender;
  set gender(GetAdminUsers200ResponseItemsInnerGenderEnum? gender) =>
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

  GetAdminUsers200ResponseItemsInnerBuilder() {
    GetAdminUsers200ResponseItemsInner._defaults(this);
  }

  GetAdminUsers200ResponseItemsInnerBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminUsers200ResponseItemsInner other) {
    _$v = other as _$GetAdminUsers200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminUsers200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsers200ResponseItemsInner build() => _build();

  _$GetAdminUsers200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminUsers200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAdminUsers200ResponseItemsInner', 'id'),
          phone: BuiltValueNullFieldError.checkNotNull(
              phone, r'GetAdminUsers200ResponseItemsInner', 'phone'),
          phoneMasked: phoneMasked,
          sesameNumber: sesameNumber,
          displayName: displayName,
          gender: BuiltValueNullFieldError.checkNotNull(
              gender, r'GetAdminUsers200ResponseItemsInner', 'gender'),
          avatarUrl: avatarUrl,
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'GetAdminUsers200ResponseItemsInner', 'avatarVersion'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(
              isEnabled, r'GetAdminUsers200ResponseItemsInner', 'isEnabled'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'GetAdminUsers200ResponseItemsInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
