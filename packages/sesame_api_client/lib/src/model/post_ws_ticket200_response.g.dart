// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ws_ticket200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostWsTicket200Response extends PostWsTicket200Response {
  @override
  final String ticket;
  @override
  final int expiresIn;

  factory _$PostWsTicket200Response(
          [void Function(PostWsTicket200ResponseBuilder)? updates]) =>
      (PostWsTicket200ResponseBuilder()..update(updates))._build();

  _$PostWsTicket200Response._({required this.ticket, required this.expiresIn})
      : super._();
  @override
  PostWsTicket200Response rebuild(
          void Function(PostWsTicket200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostWsTicket200ResponseBuilder toBuilder() =>
      PostWsTicket200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostWsTicket200Response &&
        ticket == other.ticket &&
        expiresIn == other.expiresIn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ticket.hashCode);
    _$hash = $jc(_$hash, expiresIn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostWsTicket200Response')
          ..add('ticket', ticket)
          ..add('expiresIn', expiresIn))
        .toString();
  }
}

class PostWsTicket200ResponseBuilder
    implements
        Builder<PostWsTicket200Response, PostWsTicket200ResponseBuilder> {
  _$PostWsTicket200Response? _$v;

  String? _ticket;
  String? get ticket => _$this._ticket;
  set ticket(String? ticket) => _$this._ticket = ticket;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  PostWsTicket200ResponseBuilder() {
    PostWsTicket200Response._defaults(this);
  }

  PostWsTicket200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ticket = $v.ticket;
      _expiresIn = $v.expiresIn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostWsTicket200Response other) {
    _$v = other as _$PostWsTicket200Response;
  }

  @override
  void update(void Function(PostWsTicket200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostWsTicket200Response build() => _build();

  _$PostWsTicket200Response _build() {
    final _$result = _$v ??
        _$PostWsTicket200Response._(
          ticket: BuiltValueNullFieldError.checkNotNull(
              ticket, r'PostWsTicket200Response', 'ticket'),
          expiresIn: BuiltValueNullFieldError.checkNotNull(
              expiresIn, r'PostWsTicket200Response', 'expiresIn'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
