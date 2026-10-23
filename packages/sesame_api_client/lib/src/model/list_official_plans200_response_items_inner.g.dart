// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_plans200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListOfficialPlans200ResponseItemsInnerKindEnum
    _$listOfficialPlans200ResponseItemsInnerKindEnum_exercise =
    const ListOfficialPlans200ResponseItemsInnerKindEnum._('exercise');
const ListOfficialPlans200ResponseItemsInnerKindEnum
    _$listOfficialPlans200ResponseItemsInnerKindEnum_template =
    const ListOfficialPlans200ResponseItemsInnerKindEnum._('template');
const ListOfficialPlans200ResponseItemsInnerKindEnum
    _$listOfficialPlans200ResponseItemsInnerKindEnum_plan =
    const ListOfficialPlans200ResponseItemsInnerKindEnum._('plan');

ListOfficialPlans200ResponseItemsInnerKindEnum
    _$listOfficialPlans200ResponseItemsInnerKindEnumValueOf(String name) {
  switch (name) {
    case 'exercise':
      return _$listOfficialPlans200ResponseItemsInnerKindEnum_exercise;
    case 'template':
      return _$listOfficialPlans200ResponseItemsInnerKindEnum_template;
    case 'plan':
      return _$listOfficialPlans200ResponseItemsInnerKindEnum_plan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListOfficialPlans200ResponseItemsInnerKindEnum>
    _$listOfficialPlans200ResponseItemsInnerKindEnumValues = BuiltSet<
        ListOfficialPlans200ResponseItemsInnerKindEnum>(const <ListOfficialPlans200ResponseItemsInnerKindEnum>[
  _$listOfficialPlans200ResponseItemsInnerKindEnum_exercise,
  _$listOfficialPlans200ResponseItemsInnerKindEnum_template,
  _$listOfficialPlans200ResponseItemsInnerKindEnum_plan,
]);

Serializer<ListOfficialPlans200ResponseItemsInnerKindEnum>
    _$listOfficialPlans200ResponseItemsInnerKindEnumSerializer =
    _$ListOfficialPlans200ResponseItemsInnerKindEnumSerializer();

class _$ListOfficialPlans200ResponseItemsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<ListOfficialPlans200ResponseItemsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'exercise': 'exercise',
    'template': 'template',
    'plan': 'plan',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'exercise': 'exercise',
    'template': 'template',
    'plan': 'plan',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ListOfficialPlans200ResponseItemsInnerKindEnum
  ];
  @override
  final String wireName = 'ListOfficialPlans200ResponseItemsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          ListOfficialPlans200ResponseItemsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListOfficialPlans200ResponseItemsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListOfficialPlans200ResponseItemsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ListOfficialPlans200ResponseItemsInner
    extends ListOfficialPlans200ResponseItemsInner {
  @override
  final String id;
  @override
  final ListOfficialPlans200ResponseItemsInnerKindEnum kind;
  @override
  final int version;
  @override
  final GetFitnessLibrary200ResponsePlansInner content;
  @override
  final bool isEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? updatedBy;

  factory _$ListOfficialPlans200ResponseItemsInner(
          [void Function(ListOfficialPlans200ResponseItemsInnerBuilder)?
              updates]) =>
      (ListOfficialPlans200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$ListOfficialPlans200ResponseItemsInner._(
      {required this.id,
      required this.kind,
      required this.version,
      required this.content,
      required this.isEnabled,
      required this.createdAt,
      required this.updatedAt,
      this.updatedBy})
      : super._();
  @override
  ListOfficialPlans200ResponseItemsInner rebuild(
          void Function(ListOfficialPlans200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialPlans200ResponseItemsInnerBuilder toBuilder() =>
      ListOfficialPlans200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialPlans200ResponseItemsInner &&
        id == other.id &&
        kind == other.kind &&
        version == other.version &&
        content == other.content &&
        isEnabled == other.isEnabled &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        updatedBy == other.updatedBy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListOfficialPlans200ResponseItemsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('version', version)
          ..add('content', content)
          ..add('isEnabled', isEnabled)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('updatedBy', updatedBy))
        .toString();
  }
}

class ListOfficialPlans200ResponseItemsInnerBuilder
    implements
        Builder<ListOfficialPlans200ResponseItemsInner,
            ListOfficialPlans200ResponseItemsInnerBuilder> {
  _$ListOfficialPlans200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListOfficialPlans200ResponseItemsInnerKindEnum? _kind;
  ListOfficialPlans200ResponseItemsInnerKindEnum? get kind => _$this._kind;
  set kind(ListOfficialPlans200ResponseItemsInnerKindEnum? kind) =>
      _$this._kind = kind;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  GetFitnessLibrary200ResponsePlansInnerBuilder? _content;
  GetFitnessLibrary200ResponsePlansInnerBuilder get content =>
      _$this._content ??= GetFitnessLibrary200ResponsePlansInnerBuilder();
  set content(GetFitnessLibrary200ResponsePlansInnerBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  ListOfficialPlans200ResponseItemsInnerBuilder() {
    ListOfficialPlans200ResponseItemsInner._defaults(this);
  }

  ListOfficialPlans200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _version = $v.version;
      _content = $v.content.toBuilder();
      _isEnabled = $v.isEnabled;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _updatedBy = $v.updatedBy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialPlans200ResponseItemsInner other) {
    _$v = other as _$ListOfficialPlans200ResponseItemsInner;
  }

  @override
  void update(
      void Function(ListOfficialPlans200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialPlans200ResponseItemsInner build() => _build();

  _$ListOfficialPlans200ResponseItemsInner _build() {
    _$ListOfficialPlans200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$ListOfficialPlans200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ListOfficialPlans200ResponseItemsInner', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'ListOfficialPlans200ResponseItemsInner', 'kind'),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'ListOfficialPlans200ResponseItemsInner', 'version'),
            content: content.build(),
            isEnabled: BuiltValueNullFieldError.checkNotNull(isEnabled,
                r'ListOfficialPlans200ResponseItemsInner', 'isEnabled'),
            createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
                r'ListOfficialPlans200ResponseItemsInner', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'ListOfficialPlans200ResponseItemsInner', 'updatedAt'),
            updatedBy: updatedBy,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialPlans200ResponseItemsInner',
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
