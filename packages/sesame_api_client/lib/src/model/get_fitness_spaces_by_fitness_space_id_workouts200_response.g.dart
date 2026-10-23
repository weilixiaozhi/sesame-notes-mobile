// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200Response {
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      items;
  @override
  final String? nextCursor;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdWorkouts200Response &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdWorkouts200Response,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response? _$v;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>?
      _items;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      get items => _$this._items ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>();
  set items(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdWorkouts200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response;
  }

  @override
  void update(
      void Function(GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200Response',
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
