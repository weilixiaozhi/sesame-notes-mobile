// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_register201_response_user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAuthRegister201ResponseUserGenderEnum
    _$postAuthRegister201ResponseUserGenderEnum_UNSPECIFIED =
    const PostAuthRegister201ResponseUserGenderEnum._('UNSPECIFIED');
const PostAuthRegister201ResponseUserGenderEnum
    _$postAuthRegister201ResponseUserGenderEnum_MALE =
    const PostAuthRegister201ResponseUserGenderEnum._('MALE');
const PostAuthRegister201ResponseUserGenderEnum
    _$postAuthRegister201ResponseUserGenderEnum_FEMALE =
    const PostAuthRegister201ResponseUserGenderEnum._('FEMALE');

PostAuthRegister201ResponseUserGenderEnum
    _$postAuthRegister201ResponseUserGenderEnumValueOf(String name) {
  switch (name) {
    case 'UNSPECIFIED':
      return _$postAuthRegister201ResponseUserGenderEnum_UNSPECIFIED;
    case 'MALE':
      return _$postAuthRegister201ResponseUserGenderEnum_MALE;
    case 'FEMALE':
      return _$postAuthRegister201ResponseUserGenderEnum_FEMALE;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAuthRegister201ResponseUserGenderEnum>
    _$postAuthRegister201ResponseUserGenderEnumValues = BuiltSet<
        PostAuthRegister201ResponseUserGenderEnum>(const <PostAuthRegister201ResponseUserGenderEnum>[
  _$postAuthRegister201ResponseUserGenderEnum_UNSPECIFIED,
  _$postAuthRegister201ResponseUserGenderEnum_MALE,
  _$postAuthRegister201ResponseUserGenderEnum_FEMALE,
]);

Serializer<PostAuthRegister201ResponseUserGenderEnum>
    _$postAuthRegister201ResponseUserGenderEnumSerializer =
    _$PostAuthRegister201ResponseUserGenderEnumSerializer();

class _$PostAuthRegister201ResponseUserGenderEnumSerializer
    implements PrimitiveSerializer<PostAuthRegister201ResponseUserGenderEnum> {
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
    PostAuthRegister201ResponseUserGenderEnum
  ];
  @override
  final String wireName = 'PostAuthRegister201ResponseUserGenderEnum';

  @override
  Object serialize(Serializers serializers,
          PostAuthRegister201ResponseUserGenderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAuthRegister201ResponseUserGenderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAuthRegister201ResponseUserGenderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAuthRegister201ResponseUser
    extends PostAuthRegister201ResponseUser {
  @override
  final String userId;
  @override
  final String sesameNumber;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final String? phoneMasked;
  @override
  final PostAuthRegister201ResponseUserGenderEnum gender;
  @override
  final bool isAdmin;

  factory _$PostAuthRegister201ResponseUser(
          [void Function(PostAuthRegister201ResponseUserBuilder)? updates]) =>
      (PostAuthRegister201ResponseUserBuilder()..update(updates))._build();

  _$PostAuthRegister201ResponseUser._(
      {required this.userId,
      required this.sesameNumber,
      this.displayName,
      this.avatarUrl,
      required this.avatarVersion,
      this.phoneMasked,
      required this.gender,
      required this.isAdmin})
      : super._();
  @override
  PostAuthRegister201ResponseUser rebuild(
          void Function(PostAuthRegister201ResponseUserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthRegister201ResponseUserBuilder toBuilder() =>
      PostAuthRegister201ResponseUserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthRegister201ResponseUser &&
        userId == other.userId &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        phoneMasked == other.phoneMasked &&
        gender == other.gender &&
        isAdmin == other.isAdmin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, phoneMasked.hashCode);
    _$hash = $jc(_$hash, gender.hashCode);
    _$hash = $jc(_$hash, isAdmin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthRegister201ResponseUser')
          ..add('userId', userId)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('phoneMasked', phoneMasked)
          ..add('gender', gender)
          ..add('isAdmin', isAdmin))
        .toString();
  }
}

class PostAuthRegister201ResponseUserBuilder
    implements
        Builder<PostAuthRegister201ResponseUser,
            PostAuthRegister201ResponseUserBuilder> {
  _$PostAuthRegister201ResponseUser? _$v;

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

  String? _phoneMasked;
  String? get phoneMasked => _$this._phoneMasked;
  set phoneMasked(String? phoneMasked) => _$this._phoneMasked = phoneMasked;

  PostAuthRegister201ResponseUserGenderEnum? _gender;
  PostAuthRegister201ResponseUserGenderEnum? get gender => _$this._gender;
  set gender(PostAuthRegister201ResponseUserGenderEnum? gender) =>
      _$this._gender = gender;

  bool? _isAdmin;
  bool? get isAdmin => _$this._isAdmin;
  set isAdmin(bool? isAdmin) => _$this._isAdmin = isAdmin;

  PostAuthRegister201ResponseUserBuilder() {
    PostAuthRegister201ResponseUser._defaults(this);
  }

  PostAuthRegister201ResponseUserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _sesameNumber = $v.sesameNumber;
      _displayName = $v.displayName;
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _phoneMasked = $v.phoneMasked;
      _gender = $v.gender;
      _isAdmin = $v.isAdmin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthRegister201ResponseUser other) {
    _$v = other as _$PostAuthRegister201ResponseUser;
  }

  @override
  void update(void Function(PostAuthRegister201ResponseUserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthRegister201ResponseUser build() => _build();

  _$PostAuthRegister201ResponseUser _build() {
    final _$result = _$v ??
        _$PostAuthRegister201ResponseUser._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'PostAuthRegister201ResponseUser', 'userId'),
          sesameNumber: BuiltValueNullFieldError.checkNotNull(
              sesameNumber, r'PostAuthRegister201ResponseUser', 'sesameNumber'),
          displayName: displayName,
          avatarUrl: avatarUrl,
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'PostAuthRegister201ResponseUser', 'avatarVersion'),
          phoneMasked: phoneMasked,
          gender: BuiltValueNullFieldError.checkNotNull(
              gender, r'PostAuthRegister201ResponseUser', 'gender'),
          isAdmin: BuiltValueNullFieldError.checkNotNull(
              isAdmin, r'PostAuthRegister201ResponseUser', 'isAdmin'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
