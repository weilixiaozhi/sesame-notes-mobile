// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_catalog_origin.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnum_official =
    const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
        ._('official');

GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumValueOf(
        String name) {
  switch (name) {
    case 'official':
      return _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnum_official;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>(const <GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>[
  _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnum_official,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_EnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_EnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'official': 'official',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'official': 'official',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
    extends GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin {
  @override
  final GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
      source_;
  @override
  final String itemId;
  @override
  final int revision;

  factory _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin._(
      {required this.source_, required this.itemId, required this.revision})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin &&
        source_ == other.source_ &&
        itemId == other.itemId &&
        revision == other.revision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin')
          ..add('source_', source_)
          ..add('itemId', itemId)
          ..add('revision', revision))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?
      _$v;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum?
      _source_;
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum?
      get source_ => _$this._source_;
  set source_(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum?
              source_) =>
      _$this._source_ = source_;

  String? _itemId;
  String? get itemId => _$this._itemId;
  set itemId(String? itemId) => _$this._itemId = itemId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder() {
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _source_ = $v.source_;
      _itemId = $v.itemId;
      _revision = $v.revision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
            ._(
          source_: BuiltValueNullFieldError.checkNotNull(
              source_,
              r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin',
              'source_'),
          itemId: BuiltValueNullFieldError.checkNotNull(
              itemId,
              r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin',
              'itemId'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin',
              'revision'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
