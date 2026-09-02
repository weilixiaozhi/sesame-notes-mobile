// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_imports400_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdImports400ResponseCodeEnum
    _$postLedgersByLedgerIdImports400ResponseCodeEnum_IMPORT_VALIDATION_FAILED =
    const PostLedgersByLedgerIdImports400ResponseCodeEnum._(
        'IMPORT_VALIDATION_FAILED');

PostLedgersByLedgerIdImports400ResponseCodeEnum
    _$postLedgersByLedgerIdImports400ResponseCodeEnumValueOf(String name) {
  switch (name) {
    case 'IMPORT_VALIDATION_FAILED':
      return _$postLedgersByLedgerIdImports400ResponseCodeEnum_IMPORT_VALIDATION_FAILED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdImports400ResponseCodeEnum>
    _$postLedgersByLedgerIdImports400ResponseCodeEnumValues = BuiltSet<
        PostLedgersByLedgerIdImports400ResponseCodeEnum>(const <PostLedgersByLedgerIdImports400ResponseCodeEnum>[
  _$postLedgersByLedgerIdImports400ResponseCodeEnum_IMPORT_VALIDATION_FAILED,
]);

Serializer<PostLedgersByLedgerIdImports400ResponseCodeEnum>
    _$postLedgersByLedgerIdImports400ResponseCodeEnumSerializer =
    _$PostLedgersByLedgerIdImports400ResponseCodeEnumSerializer();

class _$PostLedgersByLedgerIdImports400ResponseCodeEnumSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdImports400ResponseCodeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'IMPORT_VALIDATION_FAILED': 'IMPORT_VALIDATION_FAILED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'IMPORT_VALIDATION_FAILED': 'IMPORT_VALIDATION_FAILED',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostLedgersByLedgerIdImports400ResponseCodeEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdImports400ResponseCodeEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdImports400ResponseCodeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdImports400ResponseCodeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdImports400ResponseCodeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdImports400Response
    extends PostLedgersByLedgerIdImports400Response {
  @override
  final PostLedgersByLedgerIdImports400ResponseCodeEnum code;
  @override
  final String message;
  @override
  final String requestId;
  @override
  final BuiltList<PostLedgersByLedgerIdImports400ResponseDetailsInner> details;

  factory _$PostLedgersByLedgerIdImports400Response(
          [void Function(PostLedgersByLedgerIdImports400ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdImports400ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdImports400Response._(
      {required this.code,
      required this.message,
      required this.requestId,
      required this.details})
      : super._();
  @override
  PostLedgersByLedgerIdImports400Response rebuild(
          void Function(PostLedgersByLedgerIdImports400ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdImports400ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdImports400ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdImports400Response &&
        code == other.code &&
        message == other.message &&
        requestId == other.requestId &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, requestId.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdImports400Response')
          ..add('code', code)
          ..add('message', message)
          ..add('requestId', requestId)
          ..add('details', details))
        .toString();
  }
}

class PostLedgersByLedgerIdImports400ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdImports400Response,
            PostLedgersByLedgerIdImports400ResponseBuilder> {
  _$PostLedgersByLedgerIdImports400Response? _$v;

  PostLedgersByLedgerIdImports400ResponseCodeEnum? _code;
  PostLedgersByLedgerIdImports400ResponseCodeEnum? get code => _$this._code;
  set code(PostLedgersByLedgerIdImports400ResponseCodeEnum? code) =>
      _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  String? _requestId;
  String? get requestId => _$this._requestId;
  set requestId(String? requestId) => _$this._requestId = requestId;

  ListBuilder<PostLedgersByLedgerIdImports400ResponseDetailsInner>? _details;
  ListBuilder<PostLedgersByLedgerIdImports400ResponseDetailsInner>
      get details => _$this._details ??=
          ListBuilder<PostLedgersByLedgerIdImports400ResponseDetailsInner>();
  set details(
          ListBuilder<PostLedgersByLedgerIdImports400ResponseDetailsInner>?
              details) =>
      _$this._details = details;

  PostLedgersByLedgerIdImports400ResponseBuilder() {
    PostLedgersByLedgerIdImports400Response._defaults(this);
  }

  PostLedgersByLedgerIdImports400ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _requestId = $v.requestId;
      _details = $v.details.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdImports400Response other) {
    _$v = other as _$PostLedgersByLedgerIdImports400Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdImports400ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdImports400Response build() => _build();

  _$PostLedgersByLedgerIdImports400Response _build() {
    _$PostLedgersByLedgerIdImports400Response _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdImports400Response._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'PostLedgersByLedgerIdImports400Response', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'PostLedgersByLedgerIdImports400Response', 'message'),
            requestId: BuiltValueNullFieldError.checkNotNull(requestId,
                r'PostLedgersByLedgerIdImports400Response', 'requestId'),
            details: details.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'details';
        details.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdImports400Response',
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
