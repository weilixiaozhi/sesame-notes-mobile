// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_invites_by_code_accept200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostInvitesByCodeAccept200ResponseRoleEnum
    _$postInvitesByCodeAccept200ResponseRoleEnum_editor =
    const PostInvitesByCodeAccept200ResponseRoleEnum._('editor');

PostInvitesByCodeAccept200ResponseRoleEnum
    _$postInvitesByCodeAccept200ResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'editor':
      return _$postInvitesByCodeAccept200ResponseRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostInvitesByCodeAccept200ResponseRoleEnum>
    _$postInvitesByCodeAccept200ResponseRoleEnumValues = BuiltSet<
        PostInvitesByCodeAccept200ResponseRoleEnum>(const <PostInvitesByCodeAccept200ResponseRoleEnum>[
  _$postInvitesByCodeAccept200ResponseRoleEnum_editor,
]);

Serializer<PostInvitesByCodeAccept200ResponseRoleEnum>
    _$postInvitesByCodeAccept200ResponseRoleEnumSerializer =
    _$PostInvitesByCodeAccept200ResponseRoleEnumSerializer();

class _$PostInvitesByCodeAccept200ResponseRoleEnumSerializer
    implements PrimitiveSerializer<PostInvitesByCodeAccept200ResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostInvitesByCodeAccept200ResponseRoleEnum
  ];
  @override
  final String wireName = 'PostInvitesByCodeAccept200ResponseRoleEnum';

  @override
  Object serialize(Serializers serializers,
          PostInvitesByCodeAccept200ResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostInvitesByCodeAccept200ResponseRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostInvitesByCodeAccept200ResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostInvitesByCodeAccept200Response
    extends PostInvitesByCodeAccept200Response {
  @override
  final String ledgerId;
  @override
  final String ledgerName;
  @override
  final PostInvitesByCodeAccept200ResponseRoleEnum role;

  factory _$PostInvitesByCodeAccept200Response(
          [void Function(PostInvitesByCodeAccept200ResponseBuilder)?
              updates]) =>
      (PostInvitesByCodeAccept200ResponseBuilder()..update(updates))._build();

  _$PostInvitesByCodeAccept200Response._(
      {required this.ledgerId, required this.ledgerName, required this.role})
      : super._();
  @override
  PostInvitesByCodeAccept200Response rebuild(
          void Function(PostInvitesByCodeAccept200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostInvitesByCodeAccept200ResponseBuilder toBuilder() =>
      PostInvitesByCodeAccept200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostInvitesByCodeAccept200Response &&
        ledgerId == other.ledgerId &&
        ledgerName == other.ledgerName &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, ledgerName.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostInvitesByCodeAccept200Response')
          ..add('ledgerId', ledgerId)
          ..add('ledgerName', ledgerName)
          ..add('role', role))
        .toString();
  }
}

class PostInvitesByCodeAccept200ResponseBuilder
    implements
        Builder<PostInvitesByCodeAccept200Response,
            PostInvitesByCodeAccept200ResponseBuilder> {
  _$PostInvitesByCodeAccept200Response? _$v;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _ledgerName;
  String? get ledgerName => _$this._ledgerName;
  set ledgerName(String? ledgerName) => _$this._ledgerName = ledgerName;

  PostInvitesByCodeAccept200ResponseRoleEnum? _role;
  PostInvitesByCodeAccept200ResponseRoleEnum? get role => _$this._role;
  set role(PostInvitesByCodeAccept200ResponseRoleEnum? role) =>
      _$this._role = role;

  PostInvitesByCodeAccept200ResponseBuilder() {
    PostInvitesByCodeAccept200Response._defaults(this);
  }

  PostInvitesByCodeAccept200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerId = $v.ledgerId;
      _ledgerName = $v.ledgerName;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostInvitesByCodeAccept200Response other) {
    _$v = other as _$PostInvitesByCodeAccept200Response;
  }

  @override
  void update(
      void Function(PostInvitesByCodeAccept200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostInvitesByCodeAccept200Response build() => _build();

  _$PostInvitesByCodeAccept200Response _build() {
    final _$result = _$v ??
        _$PostInvitesByCodeAccept200Response._(
          ledgerId: BuiltValueNullFieldError.checkNotNull(
              ledgerId, r'PostInvitesByCodeAccept200Response', 'ledgerId'),
          ledgerName: BuiltValueNullFieldError.checkNotNull(
              ledgerName, r'PostInvitesByCodeAccept200Response', 'ledgerName'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'PostInvitesByCodeAccept200Response', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
