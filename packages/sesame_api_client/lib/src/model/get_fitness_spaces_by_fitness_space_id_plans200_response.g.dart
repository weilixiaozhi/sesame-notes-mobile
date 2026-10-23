// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPlans200Response
    extends GetFitnessSpacesByFitnessSpaceIdPlans200Response {
  @override
  final BuiltList<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>
      items;
  @override
  final String? nextCursor;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200Response rebuild(
          void Function(GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdPlans200Response &&
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
            r'GetFitnessSpacesByFitnessSpaceIdPlans200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdPlans200Response,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200Response? _$v;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>?
      _items;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>
      get items => _$this._items ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>();
  set items(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdPlans200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdPlans200Response;
  }

  @override
  void update(
      void Function(GetFitnessSpacesByFitnessSpaceIdPlans200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200Response._(
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
            r'GetFitnessSpacesByFitnessSpaceIdPlans200Response',
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
