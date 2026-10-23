// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_browser_register201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAuthBrowserRegister201ResponseTokenTypeEnum
    _$postAuthBrowserRegister201ResponseTokenTypeEnum_bearer =
    const PostAuthBrowserRegister201ResponseTokenTypeEnum._('bearer');

PostAuthBrowserRegister201ResponseTokenTypeEnum
    _$postAuthBrowserRegister201ResponseTokenTypeEnumValueOf(String name) {
  switch (name) {
    case 'bearer':
      return _$postAuthBrowserRegister201ResponseTokenTypeEnum_bearer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAuthBrowserRegister201ResponseTokenTypeEnum>
    _$postAuthBrowserRegister201ResponseTokenTypeEnumValues = BuiltSet<
        PostAuthBrowserRegister201ResponseTokenTypeEnum>(const <PostAuthBrowserRegister201ResponseTokenTypeEnum>[
  _$postAuthBrowserRegister201ResponseTokenTypeEnum_bearer,
]);

Serializer<PostAuthBrowserRegister201ResponseTokenTypeEnum>
    _$postAuthBrowserRegister201ResponseTokenTypeEnumSerializer =
    _$PostAuthBrowserRegister201ResponseTokenTypeEnumSerializer();

class _$PostAuthBrowserRegister201ResponseTokenTypeEnumSerializer
    implements
        PrimitiveSerializer<PostAuthBrowserRegister201ResponseTokenTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bearer': 'Bearer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'Bearer': 'bearer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAuthBrowserRegister201ResponseTokenTypeEnum
  ];
  @override
  final String wireName = 'PostAuthBrowserRegister201ResponseTokenTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostAuthBrowserRegister201ResponseTokenTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAuthBrowserRegister201ResponseTokenTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAuthBrowserRegister201ResponseTokenTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAuthBrowserRegister201Response
    extends PostAuthBrowserRegister201Response {
  @override
  final String accessToken;
  @override
  final PostAuthBrowserRegister201ResponseTokenTypeEnum tokenType;
  @override
  final int expiresIn;
  @override
  final String deviceId;
  @override
  final BuiltList<String> scopes;
  @override
  final PostAuthRegister201ResponseUser user;

  factory _$PostAuthBrowserRegister201Response(
          [void Function(PostAuthBrowserRegister201ResponseBuilder)?
              updates]) =>
      (PostAuthBrowserRegister201ResponseBuilder()..update(updates))._build();

  _$PostAuthBrowserRegister201Response._(
      {required this.accessToken,
      required this.tokenType,
      required this.expiresIn,
      required this.deviceId,
      required this.scopes,
      required this.user})
      : super._();
  @override
  PostAuthBrowserRegister201Response rebuild(
          void Function(PostAuthBrowserRegister201ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthBrowserRegister201ResponseBuilder toBuilder() =>
      PostAuthBrowserRegister201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthBrowserRegister201Response &&
        accessToken == other.accessToken &&
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
    return (newBuiltValueToStringHelper(r'PostAuthBrowserRegister201Response')
          ..add('accessToken', accessToken)
          ..add('tokenType', tokenType)
          ..add('expiresIn', expiresIn)
          ..add('deviceId', deviceId)
          ..add('scopes', scopes)
          ..add('user', user))
        .toString();
  }
}

class PostAuthBrowserRegister201ResponseBuilder
    implements
        Builder<PostAuthBrowserRegister201Response,
            PostAuthBrowserRegister201ResponseBuilder> {
  _$PostAuthBrowserRegister201Response? _$v;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  PostAuthBrowserRegister201ResponseTokenTypeEnum? _tokenType;
  PostAuthBrowserRegister201ResponseTokenTypeEnum? get tokenType =>
      _$this._tokenType;
  set tokenType(PostAuthBrowserRegister201ResponseTokenTypeEnum? tokenType) =>
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

  PostAuthBrowserRegister201ResponseBuilder() {
    PostAuthBrowserRegister201Response._defaults(this);
  }

  PostAuthBrowserRegister201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accessToken = $v.accessToken;
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
  void replace(PostAuthBrowserRegister201Response other) {
    _$v = other as _$PostAuthBrowserRegister201Response;
  }

  @override
  void update(
      void Function(PostAuthBrowserRegister201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthBrowserRegister201Response build() => _build();

  _$PostAuthBrowserRegister201Response _build() {
    _$PostAuthBrowserRegister201Response _$result;
    try {
      _$result = _$v ??
          _$PostAuthBrowserRegister201Response._(
            accessToken: BuiltValueNullFieldError.checkNotNull(accessToken,
                r'PostAuthBrowserRegister201Response', 'accessToken'),
            tokenType: BuiltValueNullFieldError.checkNotNull(
                tokenType, r'PostAuthBrowserRegister201Response', 'tokenType'),
            expiresIn: BuiltValueNullFieldError.checkNotNull(
                expiresIn, r'PostAuthBrowserRegister201Response', 'expiresIn'),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'PostAuthBrowserRegister201Response', 'deviceId'),
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
            r'PostAuthBrowserRegister201Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
