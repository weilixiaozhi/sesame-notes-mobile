// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_exercises200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListOfficialExercises200ResponseItemsInnerKindEnum
    _$listOfficialExercises200ResponseItemsInnerKindEnum_exercise =
    const ListOfficialExercises200ResponseItemsInnerKindEnum._('exercise');
const ListOfficialExercises200ResponseItemsInnerKindEnum
    _$listOfficialExercises200ResponseItemsInnerKindEnum_template =
    const ListOfficialExercises200ResponseItemsInnerKindEnum._('template');
const ListOfficialExercises200ResponseItemsInnerKindEnum
    _$listOfficialExercises200ResponseItemsInnerKindEnum_plan =
    const ListOfficialExercises200ResponseItemsInnerKindEnum._('plan');

ListOfficialExercises200ResponseItemsInnerKindEnum
    _$listOfficialExercises200ResponseItemsInnerKindEnumValueOf(String name) {
  switch (name) {
    case 'exercise':
      return _$listOfficialExercises200ResponseItemsInnerKindEnum_exercise;
    case 'template':
      return _$listOfficialExercises200ResponseItemsInnerKindEnum_template;
    case 'plan':
      return _$listOfficialExercises200ResponseItemsInnerKindEnum_plan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListOfficialExercises200ResponseItemsInnerKindEnum>
    _$listOfficialExercises200ResponseItemsInnerKindEnumValues = BuiltSet<
        ListOfficialExercises200ResponseItemsInnerKindEnum>(const <ListOfficialExercises200ResponseItemsInnerKindEnum>[
  _$listOfficialExercises200ResponseItemsInnerKindEnum_exercise,
  _$listOfficialExercises200ResponseItemsInnerKindEnum_template,
  _$listOfficialExercises200ResponseItemsInnerKindEnum_plan,
]);

Serializer<ListOfficialExercises200ResponseItemsInnerKindEnum>
    _$listOfficialExercises200ResponseItemsInnerKindEnumSerializer =
    _$ListOfficialExercises200ResponseItemsInnerKindEnumSerializer();

class _$ListOfficialExercises200ResponseItemsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            ListOfficialExercises200ResponseItemsInnerKindEnum> {
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
    ListOfficialExercises200ResponseItemsInnerKindEnum
  ];
  @override
  final String wireName = 'ListOfficialExercises200ResponseItemsInnerKindEnum';

  @override
  Object serialize(Serializers serializers,
          ListOfficialExercises200ResponseItemsInnerKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListOfficialExercises200ResponseItemsInnerKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListOfficialExercises200ResponseItemsInnerKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ListOfficialExercises200ResponseItemsInner
    extends ListOfficialExercises200ResponseItemsInner {
  @override
  final String id;
  @override
  final ListOfficialExercises200ResponseItemsInnerKindEnum kind;
  @override
  final int version;
  @override
  final ListOfficialExercises200ResponseItemsInnerContent content;
  @override
  final bool isEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? updatedBy;

  factory _$ListOfficialExercises200ResponseItemsInner(
          [void Function(ListOfficialExercises200ResponseItemsInnerBuilder)?
              updates]) =>
      (ListOfficialExercises200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$ListOfficialExercises200ResponseItemsInner._(
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
  ListOfficialExercises200ResponseItemsInner rebuild(
          void Function(ListOfficialExercises200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialExercises200ResponseItemsInnerBuilder toBuilder() =>
      ListOfficialExercises200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialExercises200ResponseItemsInner &&
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
            r'ListOfficialExercises200ResponseItemsInner')
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

class ListOfficialExercises200ResponseItemsInnerBuilder
    implements
        Builder<ListOfficialExercises200ResponseItemsInner,
            ListOfficialExercises200ResponseItemsInnerBuilder> {
  _$ListOfficialExercises200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListOfficialExercises200ResponseItemsInnerKindEnum? _kind;
  ListOfficialExercises200ResponseItemsInnerKindEnum? get kind => _$this._kind;
  set kind(ListOfficialExercises200ResponseItemsInnerKindEnum? kind) =>
      _$this._kind = kind;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ListOfficialExercises200ResponseItemsInnerContentBuilder? _content;
  ListOfficialExercises200ResponseItemsInnerContentBuilder get content =>
      _$this._content ??=
          ListOfficialExercises200ResponseItemsInnerContentBuilder();
  set content(
          ListOfficialExercises200ResponseItemsInnerContentBuilder? content) =>
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

  ListOfficialExercises200ResponseItemsInnerBuilder() {
    ListOfficialExercises200ResponseItemsInner._defaults(this);
  }

  ListOfficialExercises200ResponseItemsInnerBuilder get _$this {
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
  void replace(ListOfficialExercises200ResponseItemsInner other) {
    _$v = other as _$ListOfficialExercises200ResponseItemsInner;
  }

  @override
  void update(
      void Function(ListOfficialExercises200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialExercises200ResponseItemsInner build() => _build();

  _$ListOfficialExercises200ResponseItemsInner _build() {
    _$ListOfficialExercises200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$ListOfficialExercises200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ListOfficialExercises200ResponseItemsInner', 'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind, r'ListOfficialExercises200ResponseItemsInner', 'kind'),
            version: BuiltValueNullFieldError.checkNotNull(version,
                r'ListOfficialExercises200ResponseItemsInner', 'version'),
            content: content.build(),
            isEnabled: BuiltValueNullFieldError.checkNotNull(isEnabled,
                r'ListOfficialExercises200ResponseItemsInner', 'isEnabled'),
            createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
                r'ListOfficialExercises200ResponseItemsInner', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
                r'ListOfficialExercises200ResponseItemsInner', 'updatedAt'),
            updatedBy: updatedBy,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialExercises200ResponseItemsInner',
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
