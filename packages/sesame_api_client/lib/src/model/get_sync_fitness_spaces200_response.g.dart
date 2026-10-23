// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_fitness_spaces200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFitnessSpaces200Response
    extends GetSyncFitnessSpaces200Response {
  @override
  final BuiltList<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>
      fitnessSpaces;
  @override
  final String serverCursor;

  factory _$GetSyncFitnessSpaces200Response(
          [void Function(GetSyncFitnessSpaces200ResponseBuilder)? updates]) =>
      (GetSyncFitnessSpaces200ResponseBuilder()..update(updates))._build();

  _$GetSyncFitnessSpaces200Response._(
      {required this.fitnessSpaces, required this.serverCursor})
      : super._();
  @override
  GetSyncFitnessSpaces200Response rebuild(
          void Function(GetSyncFitnessSpaces200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFitnessSpaces200ResponseBuilder toBuilder() =>
      GetSyncFitnessSpaces200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFitnessSpaces200Response &&
        fitnessSpaces == other.fitnessSpaces &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fitnessSpaces.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFitnessSpaces200Response')
          ..add('fitnessSpaces', fitnessSpaces)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncFitnessSpaces200ResponseBuilder
    implements
        Builder<GetSyncFitnessSpaces200Response,
            GetSyncFitnessSpaces200ResponseBuilder> {
  _$GetSyncFitnessSpaces200Response? _$v;

  ListBuilder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>?
      _fitnessSpaces;
  ListBuilder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>
      get fitnessSpaces => _$this._fitnessSpaces ??=
          ListBuilder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>();
  set fitnessSpaces(
          ListBuilder<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>?
              fitnessSpaces) =>
      _$this._fitnessSpaces = fitnessSpaces;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncFitnessSpaces200ResponseBuilder() {
    GetSyncFitnessSpaces200Response._defaults(this);
  }

  GetSyncFitnessSpaces200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fitnessSpaces = $v.fitnessSpaces.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFitnessSpaces200Response other) {
    _$v = other as _$GetSyncFitnessSpaces200Response;
  }

  @override
  void update(void Function(GetSyncFitnessSpaces200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFitnessSpaces200Response build() => _build();

  _$GetSyncFitnessSpaces200Response _build() {
    _$GetSyncFitnessSpaces200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncFitnessSpaces200Response._(
            fitnessSpaces: fitnessSpaces.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(serverCursor,
                r'GetSyncFitnessSpaces200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fitnessSpaces';
        fitnessSpaces.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncFitnessSpaces200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
