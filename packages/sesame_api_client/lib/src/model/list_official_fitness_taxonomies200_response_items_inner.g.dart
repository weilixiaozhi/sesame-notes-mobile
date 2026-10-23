// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_fitness_taxonomies200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
    _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_bodyPart =
    const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum._(
        'bodyPart');
const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
    _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_equipment =
    const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum._(
        'equipment');

ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
    _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'bodyPart':
      return _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_bodyPart;
    case 'equipment':
      return _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_equipment;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>
    _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumValues =
    BuiltSet<
        ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>(const <ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>[
  _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_bodyPart,
  _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_equipment,
]);

Serializer<ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>
    _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumSerializer =
    _$ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumSerializer();

class _$ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'bodyPart': 'body_part',
    'equipment': 'equipment',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'body_part': 'bodyPart',
    'equipment': 'equipment',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
  ];
  @override
  final String wireName =
      'ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ListOfficialFitnessTaxonomies200ResponseItemsInner
    extends ListOfficialFitnessTaxonomies200ResponseItemsInner {
  @override
  final String id;
  @override
  final ListOfficialFitnessTaxonomies200ResponseItemsInnerName name;
  @override
  final bool isDeleted;
  @override
  final ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum kind;
  @override
  final int sortOrder;
  @override
  final int version;
  @override
  final int exerciseCount;
  @override
  final int templateCount;

  factory _$ListOfficialFitnessTaxonomies200ResponseItemsInner(
          [void Function(
                  ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder)?
              updates]) =>
      (ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$ListOfficialFitnessTaxonomies200ResponseItemsInner._(
      {required this.id,
      required this.name,
      required this.isDeleted,
      required this.kind,
      required this.sortOrder,
      required this.version,
      required this.exerciseCount,
      required this.templateCount})
      : super._();
  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInner rebuild(
          void Function(
                  ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder toBuilder() =>
      ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialFitnessTaxonomies200ResponseItemsInner &&
        id == other.id &&
        name == other.name &&
        isDeleted == other.isDeleted &&
        kind == other.kind &&
        sortOrder == other.sortOrder &&
        version == other.version &&
        exerciseCount == other.exerciseCount &&
        templateCount == other.templateCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isDeleted.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, exerciseCount.hashCode);
    _$hash = $jc(_$hash, templateCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListOfficialFitnessTaxonomies200ResponseItemsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('isDeleted', isDeleted)
          ..add('kind', kind)
          ..add('sortOrder', sortOrder)
          ..add('version', version)
          ..add('exerciseCount', exerciseCount)
          ..add('templateCount', templateCount))
        .toString();
  }
}

class ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder
    implements
        Builder<ListOfficialFitnessTaxonomies200ResponseItemsInner,
            ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder> {
  _$ListOfficialFitnessTaxonomies200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder? _name;
  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder get name =>
      _$this._name ??=
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder();
  set name(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder?
              name) =>
      _$this._name = name;

  bool? _isDeleted;
  bool? get isDeleted => _$this._isDeleted;
  set isDeleted(bool? isDeleted) => _$this._isDeleted = isDeleted;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum? _kind;
  ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum? get kind =>
      _$this._kind;
  set kind(ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum? kind) =>
      _$this._kind = kind;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  int? _exerciseCount;
  int? get exerciseCount => _$this._exerciseCount;
  set exerciseCount(int? exerciseCount) =>
      _$this._exerciseCount = exerciseCount;

  int? _templateCount;
  int? get templateCount => _$this._templateCount;
  set templateCount(int? templateCount) =>
      _$this._templateCount = templateCount;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder() {
    ListOfficialFitnessTaxonomies200ResponseItemsInner._defaults(this);
  }

  ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name.toBuilder();
      _isDeleted = $v.isDeleted;
      _kind = $v.kind;
      _sortOrder = $v.sortOrder;
      _version = $v.version;
      _exerciseCount = $v.exerciseCount;
      _templateCount = $v.templateCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialFitnessTaxonomies200ResponseItemsInner other) {
    _$v = other as _$ListOfficialFitnessTaxonomies200ResponseItemsInner;
  }

  @override
  void update(
      void Function(ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInner build() => _build();

  _$ListOfficialFitnessTaxonomies200ResponseItemsInner _build() {
    _$ListOfficialFitnessTaxonomies200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$ListOfficialFitnessTaxonomies200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner', 'id'),
            name: name.build(),
            isDeleted: BuiltValueNullFieldError.checkNotNull(
                isDeleted,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
                'isDeleted'),
            kind: BuiltValueNullFieldError.checkNotNull(kind,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner', 'kind'),
            sortOrder: BuiltValueNullFieldError.checkNotNull(
                sortOrder,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
                'sortOrder'),
            version: BuiltValueNullFieldError.checkNotNull(
                version,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
                'version'),
            exerciseCount: BuiltValueNullFieldError.checkNotNull(
                exerciseCount,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
                'exerciseCount'),
            templateCount: BuiltValueNullFieldError.checkNotNull(
                templateCount,
                r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
                'templateCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        name.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialFitnessTaxonomies200ResponseItemsInner',
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
