// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_fitness_spaces_full200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFitnessSpacesFull200Response
    extends GetSyncFitnessSpacesFull200Response {
  @override
  final GetSyncFitnessSpacesFull200ResponseFitnessSpace fitnessSpace;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>
      fitnessTemplates;
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>
      fitnessPlans;
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      fitnessWorkouts;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      fitnessPreferences;
  @override
  final String serverCursor;

  factory _$GetSyncFitnessSpacesFull200Response(
          [void Function(GetSyncFitnessSpacesFull200ResponseBuilder)?
              updates]) =>
      (GetSyncFitnessSpacesFull200ResponseBuilder()..update(updates))._build();

  _$GetSyncFitnessSpacesFull200Response._(
      {required this.fitnessSpace,
      required this.fitnessTemplates,
      required this.fitnessPlans,
      required this.fitnessWorkouts,
      required this.fitnessPreferences,
      required this.serverCursor})
      : super._();
  @override
  GetSyncFitnessSpacesFull200Response rebuild(
          void Function(GetSyncFitnessSpacesFull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFitnessSpacesFull200ResponseBuilder toBuilder() =>
      GetSyncFitnessSpacesFull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFitnessSpacesFull200Response &&
        fitnessSpace == other.fitnessSpace &&
        fitnessTemplates == other.fitnessTemplates &&
        fitnessPlans == other.fitnessPlans &&
        fitnessWorkouts == other.fitnessWorkouts &&
        fitnessPreferences == other.fitnessPreferences &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fitnessSpace.hashCode);
    _$hash = $jc(_$hash, fitnessTemplates.hashCode);
    _$hash = $jc(_$hash, fitnessPlans.hashCode);
    _$hash = $jc(_$hash, fitnessWorkouts.hashCode);
    _$hash = $jc(_$hash, fitnessPreferences.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFitnessSpacesFull200Response')
          ..add('fitnessSpace', fitnessSpace)
          ..add('fitnessTemplates', fitnessTemplates)
          ..add('fitnessPlans', fitnessPlans)
          ..add('fitnessWorkouts', fitnessWorkouts)
          ..add('fitnessPreferences', fitnessPreferences)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncFitnessSpacesFull200ResponseBuilder
    implements
        Builder<GetSyncFitnessSpacesFull200Response,
            GetSyncFitnessSpacesFull200ResponseBuilder> {
  _$GetSyncFitnessSpacesFull200Response? _$v;

  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder? _fitnessSpace;
  GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder get fitnessSpace =>
      _$this._fitnessSpace ??=
          GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder();
  set fitnessSpace(
          GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder?
              fitnessSpace) =>
      _$this._fitnessSpace = fitnessSpace;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>?
      _fitnessTemplates;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>
      get fitnessTemplates => _$this._fitnessTemplates ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>();
  set fitnessTemplates(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>?
              fitnessTemplates) =>
      _$this._fitnessTemplates = fitnessTemplates;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>?
      _fitnessPlans;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>
      get fitnessPlans => _$this._fitnessPlans ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>();
  set fitnessPlans(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>?
              fitnessPlans) =>
      _$this._fitnessPlans = fitnessPlans;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>?
      _fitnessWorkouts;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      get fitnessWorkouts => _$this._fitnessWorkouts ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>();
  set fitnessWorkouts(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>?
              fitnessWorkouts) =>
      _$this._fitnessWorkouts = fitnessWorkouts;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>?
      _fitnessPreferences;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      get fitnessPreferences => _$this._fitnessPreferences ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>();
  set fitnessPreferences(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>?
              fitnessPreferences) =>
      _$this._fitnessPreferences = fitnessPreferences;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncFitnessSpacesFull200ResponseBuilder() {
    GetSyncFitnessSpacesFull200Response._defaults(this);
  }

  GetSyncFitnessSpacesFull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fitnessSpace = $v.fitnessSpace.toBuilder();
      _fitnessTemplates = $v.fitnessTemplates.toBuilder();
      _fitnessPlans = $v.fitnessPlans.toBuilder();
      _fitnessWorkouts = $v.fitnessWorkouts.toBuilder();
      _fitnessPreferences = $v.fitnessPreferences.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFitnessSpacesFull200Response other) {
    _$v = other as _$GetSyncFitnessSpacesFull200Response;
  }

  @override
  void update(
      void Function(GetSyncFitnessSpacesFull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFitnessSpacesFull200Response build() => _build();

  _$GetSyncFitnessSpacesFull200Response _build() {
    _$GetSyncFitnessSpacesFull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncFitnessSpacesFull200Response._(
            fitnessSpace: fitnessSpace.build(),
            fitnessTemplates: fitnessTemplates.build(),
            fitnessPlans: fitnessPlans.build(),
            fitnessWorkouts: fitnessWorkouts.build(),
            fitnessPreferences: fitnessPreferences.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(serverCursor,
                r'GetSyncFitnessSpacesFull200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fitnessSpace';
        fitnessSpace.build();
        _$failedField = 'fitnessTemplates';
        fitnessTemplates.build();
        _$failedField = 'fitnessPlans';
        fitnessPlans.build();
        _$failedField = 'fitnessWorkouts';
        fitnessWorkouts.build();
        _$failedField = 'fitnessPreferences';
        fitnessPreferences.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GetSyncFitnessSpacesFull200Response',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
