// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_templates200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response
    extends GetFitnessSpacesByFitnessSpaceIdTemplates200Response {
  @override
  final BuiltList<
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner> items;
  @override
  final String? nextCursor;

  factory _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200Response rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder toBuilder() =>
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessSpacesByFitnessSpaceIdTemplates200Response &&
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
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdTemplates200Response,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response? _$v;

  ListBuilder<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>?
      _items;
  ListBuilder<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>
      get items => _$this._items ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>();
  set items(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>?
              items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder() {
    GetFitnessSpacesByFitnessSpaceIdTemplates200Response._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessSpacesByFitnessSpaceIdTemplates200Response other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200Response build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response _build() {
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200Response._(
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
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200Response',
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
