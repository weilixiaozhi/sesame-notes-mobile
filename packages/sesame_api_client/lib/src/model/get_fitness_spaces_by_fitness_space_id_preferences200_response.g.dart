// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_preferences200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response
    extends GetFitnessSpacesByFitnessSpaceIdPreferences200Response {
  @override
  final BuiltList<
      GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner> items;
  @override
  final String? nextCursor;

  factory _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdPreferences200Response &&
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
            r'GetFitnessSpacesByFitnessSpaceIdPreferences200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdPreferences200Response,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response? _$v;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>?
      _items;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      get items => _$this._items ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>();
  set items(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPreferences200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdPreferences200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response._(
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
            r'GetFitnessSpacesByFitnessSpaceIdPreferences200Response',
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
