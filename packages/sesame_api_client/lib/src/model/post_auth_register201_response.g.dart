// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_register201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAuthRegister201ResponseTokenTypeEnum
    _$postAuthRegister201ResponseTokenTypeEnum_bearer =
    const PostAuthRegister201ResponseTokenTypeEnum._('bearer');

PostAuthRegister201ResponseTokenTypeEnum
    _$postAuthRegister201ResponseTokenTypeEnumValueOf(String name) {
  switch (name) {
    case 'bearer':
      return _$postAuthRegister201ResponseTokenTypeEnum_bearer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAuthRegister201ResponseTokenTypeEnum>
    _$postAuthRegister201ResponseTokenTypeEnumValues = BuiltSet<
        PostAuthRegister201ResponseTokenTypeEnum>(const <PostAuthRegister201ResponseTokenTypeEnum>[
  _$postAuthRegister201ResponseTokenTypeEnum_bearer,
]);

Serializer<PostAuthRegister201ResponseTokenTypeEnum>
    _$postAuthRegister201ResponseTokenTypeEnumSerializer =
    _$PostAuthRegister201ResponseTokenTypeEnumSerializer();

class _$PostAuthRegister201ResponseTokenTypeEnumSerializer
    implements PrimitiveSerializer<PostAuthRegister201ResponseTokenTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bearer': 'Bearer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Bearer': 'bearer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAuthRegister201ResponseTokenTypeEnum
  ];
  @override
  final String wireName = 'PostAuthRegister201ResponseTokenTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostAuthRegister201ResponseTokenTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAuthRegister201ResponseTokenTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAuthRegister201ResponseTokenTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAuthRegister201Response extends PostAuthRegister201Response {
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final PostAuthRegister201ResponseTokenTypeEnum tokenType;
  @override
  final int expiresIn;
  @override
  final String deviceId;
  @override
  final BuiltList<String> scopes;
  @override
  final PostAuthRegister201ResponseUser user;

  factory _$PostAuthRegister201Response(
          [void Function(PostAuthRegister201ResponseBuilder)? updates]) =>
      (PostAuthRegister201ResponseBuilder()..update(updates))._build();

  _$PostAuthRegister201Response._(
      {required this.accessToken,
      required this.refreshToken,
      required this.tokenType,
      required this.expiresIn,
      required this.deviceId,
      required this.scopes,
      required this.user})
      : super._();
  @override
  PostAuthRegister201Response rebuild(
          void Function(PostAuthRegister201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthRegister201ResponseBuilder toBuilder() =>
      PostAuthRegister201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthRegister201Response &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        tokenType == other.tokenType &&
        expiresIn == other.expiresIn &&
        deviceId == other.deviceId &&
        scopes == other.scopes &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, tokenType.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, scopes.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthRegister201Response')
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('tokenType', tokenType)
          ..add('expiresIn', expiresIn)
          ..add('deviceId', deviceId)
          ..add('scopes', scopes)
          ..add('user', user))
        .toString();
  }
}

class PostAuthRegister201ResponseBuilder
    implements
        Builder<PostAuthRegister201Response,
            PostAuthRegister201ResponseBuilder> {
  _$PostAuthRegister201Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  PostAuthRegister201ResponseTokenTypeEnum? _tokenType;
  PostAuthRegister201ResponseTokenTypeEnum? get tokenType => _$this._tokenType;
  set tokenType(PostAuthRegister201ResponseTokenTypeEnum? tokenType) =>
      _$this._tokenType = tokenType;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  ListBuilder<String>? _scopes;
  ListBuilder<String> get scopes => _$this._scopes ??= ListBuilder<String>();
  set scopes(ListBuilder<String>? scopes) => _$this._scopes = scopes;

  PostAuthRegister201ResponseUserBuilder? _user;
  PostAuthRegister201ResponseUserBuilder get user =>
      _$this._user ??= PostAuthRegister201ResponseUserBuilder();
  set user(PostAuthRegister201ResponseUserBuilder? user) => _$this._user = user;

  PostAuthRegister201ResponseBuilder() {
    PostAuthRegister201Response._defaults(this);
  }

  PostAuthRegister201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _tokenType = $v.tokenType;
      _expiresIn = $v.expiresIn;
      _deviceId = $v.deviceId;
      _scopes = $v.scopes.toBuilder();
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthRegister201Response other) {
    _$v = other as _$PostAuthRegister201Response;
  }

  @override
  void update(void Function(PostAuthRegister201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthRegister201Response build() => _build();

  _$PostAuthRegister201Response _build() {
    _$PostAuthRegister201Response _$result;
    try {
      _$result = _$v ??
          _$PostAuthRegister201Response._(
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'PostAuthRegister201Response', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'PostAuthRegister201Response', 'refreshToken'),
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'PostAuthRegister201Response', 'tokenType'),
            expiresIn: BuiltValueNullFieldError.checkNotNull(
                expiresIn, r'PostAuthRegister201Response', 'expiresIn'),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'PostAuthRegister201Response', 'deviceId'),
            scopes: scopes.build(),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'scopes';
        scopes.build();
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAuthRegister201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
