// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_invites201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdInvites201ResponseRoleEnum
    _$postLedgersByLedgerIdInvites201ResponseRoleEnum_editor =
    const PostLedgersByLedgerIdInvites201ResponseRoleEnum._('editor');

PostLedgersByLedgerIdInvites201ResponseRoleEnum
    _$postLedgersByLedgerIdInvites201ResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'editor':
      return _$postLedgersByLedgerIdInvites201ResponseRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdInvites201ResponseRoleEnum>
    _$postLedgersByLedgerIdInvites201ResponseRoleEnumValues = BuiltSet<
        PostLedgersByLedgerIdInvites201ResponseRoleEnum>(const <PostLedgersByLedgerIdInvites201ResponseRoleEnum>[
  _$postLedgersByLedgerIdInvites201ResponseRoleEnum_editor,
]);

Serializer<PostLedgersByLedgerIdInvites201ResponseRoleEnum>
    _$postLedgersByLedgerIdInvites201ResponseRoleEnumSerializer =
    _$PostLedgersByLedgerIdInvites201ResponseRoleEnumSerializer();

class _$PostLedgersByLedgerIdInvites201ResponseRoleEnumSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdInvites201ResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostLedgersByLedgerIdInvites201ResponseRoleEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdInvites201ResponseRoleEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdInvites201ResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdInvites201ResponseRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdInvites201ResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdInvites201Response
    extends PostLedgersByLedgerIdInvites201Response {
  @override
  final String id;
  @override
  final PostLedgersByLedgerIdInvites201ResponseRoleEnum role;
  @override
  final DateTime expiresAt;
  @override
  final String code;

  factory _$PostLedgersByLedgerIdInvites201Response(
          [void Function(PostLedgersByLedgerIdInvites201ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdInvites201ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdInvites201Response._(
      {required this.id,
      required this.role,
      required this.expiresAt,
      required this.code})
      : super._();
  @override
  PostLedgersByLedgerIdInvites201Response rebuild(
          void Function(PostLedgersByLedgerIdInvites201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdInvites201ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdInvites201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdInvites201Response &&
        id == other.id &&
        role == other.role &&
        expiresAt == other.expiresAt &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdInvites201Response')
          ..add('id', id)
          ..add('role', role)
          ..add('expiresAt', expiresAt)
          ..add('code', code))
        .toString();
  }
}

class PostLedgersByLedgerIdInvites201ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdInvites201Response,
            PostLedgersByLedgerIdInvites201ResponseBuilder> {
  _$PostLedgersByLedgerIdInvites201Response? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PostLedgersByLedgerIdInvites201ResponseRoleEnum? _role;
  PostLedgersByLedgerIdInvites201ResponseRoleEnum? get role => _$this._role;
  set role(PostLedgersByLedgerIdInvites201ResponseRoleEnum? role) =>
      _$this._role = role;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  PostLedgersByLedgerIdInvites201ResponseBuilder() {
    PostLedgersByLedgerIdInvites201Response._defaults(this);
  }

  PostLedgersByLedgerIdInvites201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _role = $v.role;
      _expiresAt = $v.expiresAt;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdInvites201Response other) {
    _$v = other as _$PostLedgersByLedgerIdInvites201Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdInvites201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdInvites201Response build() => _build();

  _$PostLedgersByLedgerIdInvites201Response _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdInvites201Response._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PostLedgersByLedgerIdInvites201Response', 'id'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'PostLedgersByLedgerIdInvites201Response', 'role'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(expiresAt,
              r'PostLedgersByLedgerIdInvites201Response', 'expiresAt'),
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'PostLedgersByLedgerIdInvites201Response', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
