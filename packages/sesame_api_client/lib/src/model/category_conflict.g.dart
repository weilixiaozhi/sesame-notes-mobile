// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_conflict.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CategoryConflictActionEnum _$categoryConflictActionEnum_upsert =
    const CategoryConflictActionEnum._('upsert');
const CategoryConflictActionEnum _$categoryConflictActionEnum_delete =
    const CategoryConflictActionEnum._('delete');

CategoryConflictActionEnum _$categoryConflictActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$categoryConflictActionEnum_upsert;
    case 'delete':
      return _$categoryConflictActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryConflictActionEnum> _$categoryConflictActionEnumValues =
    BuiltSet<CategoryConflictActionEnum>(const <CategoryConflictActionEnum>[
  _$categoryConflictActionEnum_upsert,
  _$categoryConflictActionEnum_delete,
]);

const CategoryConflictStatusEnum _$categoryConflictStatusEnum_pending =
    const CategoryConflictStatusEnum._('pending');
const CategoryConflictStatusEnum _$categoryConflictStatusEnum_resolved =
    const CategoryConflictStatusEnum._('resolved');

CategoryConflictStatusEnum _$categoryConflictStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$categoryConflictStatusEnum_pending;
    case 'resolved':
      return _$categoryConflictStatusEnum_resolved;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryConflictStatusEnum> _$categoryConflictStatusEnumValues =
    BuiltSet<CategoryConflictStatusEnum>(const <CategoryConflictStatusEnum>[
  _$categoryConflictStatusEnum_pending,
  _$categoryConflictStatusEnum_resolved,
]);

const CategoryConflictResolutionEnum _$categoryConflictResolutionEnum_cloud =
    const CategoryConflictResolutionEnum._('cloud');
const CategoryConflictResolutionEnum _$categoryConflictResolutionEnum_local =
    const CategoryConflictResolutionEnum._('local');

CategoryConflictResolutionEnum _$categoryConflictResolutionEnumValueOf(
    String name) {
  switch (name) {
    case 'cloud':
      return _$categoryConflictResolutionEnum_cloud;
    case 'local':
      return _$categoryConflictResolutionEnum_local;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryConflictResolutionEnum>
    _$categoryConflictResolutionEnumValues = BuiltSet<
        CategoryConflictResolutionEnum>(const <CategoryConflictResolutionEnum>[
  _$categoryConflictResolutionEnum_cloud,
  _$categoryConflictResolutionEnum_local,
]);

Serializer<CategoryConflictActionEnum> _$categoryConflictActionEnumSerializer =
    _$CategoryConflictActionEnumSerializer();
Serializer<CategoryConflictStatusEnum> _$categoryConflictStatusEnumSerializer =
    _$CategoryConflictStatusEnumSerializer();
Serializer<CategoryConflictResolutionEnum>
    _$categoryConflictResolutionEnumSerializer =
    _$CategoryConflictResolutionEnumSerializer();

class _$CategoryConflictActionEnumSerializer
    implements PrimitiveSerializer<CategoryConflictActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[CategoryConflictActionEnum];
  @override
  final String wireName = 'CategoryConflictActionEnum';

  @override
  Object serialize(Serializers serializers, CategoryConflictActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryConflictActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryConflictActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryConflictStatusEnumSerializer
    implements PrimitiveSerializer<CategoryConflictStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'resolved': 'resolved',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'resolved': 'resolved',
  };

  @override
  final Iterable<Type> types = const <Type>[CategoryConflictStatusEnum];
  @override
  final String wireName = 'CategoryConflictStatusEnum';

  @override
  Object serialize(Serializers serializers, CategoryConflictStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryConflictStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryConflictStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryConflictResolutionEnumSerializer
    implements PrimitiveSerializer<CategoryConflictResolutionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cloud': 'cloud',
    'local': 'local',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cloud': 'cloud',
    'local': 'local',
  };

  @override
  final Iterable<Type> types = const <Type>[CategoryConflictResolutionEnum];
  @override
  final String wireName = 'CategoryConflictResolutionEnum';

  @override
  Object serialize(
          Serializers serializers, CategoryConflictResolutionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryConflictResolutionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryConflictResolutionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryConflict extends CategoryConflict {
  @override
  final String id;
  @override
  final String categoryId;
  @override
  final String templateKey;
  @override
  final String sourceDeviceId;
  @override
  final String sourceMutationId;
  @override
  final int candidateVersion;
  @override
  final CategoryConflictActionEnum action;
  @override
  final CategoryConflictLocalPayload? localPayload;
  @override
  final DateTime localUpdatedAt;
  @override
  final Category cloudSnapshot;
  @override
  final CategoryConflictStatusEnum status;
  @override
  final CategoryConflictResolutionEnum? resolution;
  @override
  final DateTime createdAt;
  @override
  final DateTime? resolvedAt;

  factory _$CategoryConflict(
          [void Function(CategoryConflictBuilder)? updates]) =>
      (CategoryConflictBuilder()..update(updates))._build();

  _$CategoryConflict._(
      {required this.id,
      required this.categoryId,
      required this.templateKey,
      required this.sourceDeviceId,
      required this.sourceMutationId,
      required this.candidateVersion,
      required this.action,
      this.localPayload,
      required this.localUpdatedAt,
      required this.cloudSnapshot,
      required this.status,
      this.resolution,
      required this.createdAt,
      this.resolvedAt})
      : super._();
  @override
  CategoryConflict rebuild(void Function(CategoryConflictBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryConflictBuilder toBuilder() =>
      CategoryConflictBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CategoryConflict &&
        id == other.id &&
        categoryId == other.categoryId &&
        templateKey == other.templateKey &&
        sourceDeviceId == other.sourceDeviceId &&
        sourceMutationId == other.sourceMutationId &&
        candidateVersion == other.candidateVersion &&
        action == other.action &&
        localPayload == other.localPayload &&
        localUpdatedAt == other.localUpdatedAt &&
        cloudSnapshot == other.cloudSnapshot &&
        status == other.status &&
        resolution == other.resolution &&
        createdAt == other.createdAt &&
        resolvedAt == other.resolvedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, templateKey.hashCode);
    _$hash = $jc(_$hash, sourceDeviceId.hashCode);
    _$hash = $jc(_$hash, sourceMutationId.hashCode);
    _$hash = $jc(_$hash, candidateVersion.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, localPayload.hashCode);
    _$hash = $jc(_$hash, localUpdatedAt.hashCode);
    _$hash = $jc(_$hash, cloudSnapshot.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, resolvedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CategoryConflict')
          ..add('id', id)
          ..add('categoryId', categoryId)
          ..add('templateKey', templateKey)
          ..add('sourceDeviceId', sourceDeviceId)
          ..add('sourceMutationId', sourceMutationId)
          ..add('candidateVersion', candidateVersion)
          ..add('action', action)
          ..add('localPayload', localPayload)
          ..add('localUpdatedAt', localUpdatedAt)
          ..add('cloudSnapshot', cloudSnapshot)
          ..add('status', status)
          ..add('resolution', resolution)
          ..add('createdAt', createdAt)
          ..add('resolvedAt', resolvedAt))
        .toString();
  }
}

class CategoryConflictBuilder
    implements Builder<CategoryConflict, CategoryConflictBuilder> {
  _$CategoryConflict? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _categoryId;
  String? get categoryId => _$this._categoryId;
  set categoryId(String? categoryId) => _$this._categoryId = categoryId;

  String? _templateKey;
  String? get templateKey => _$this._templateKey;
  set templateKey(String? templateKey) => _$this._templateKey = templateKey;

  String? _sourceDeviceId;
  String? get sourceDeviceId => _$this._sourceDeviceId;
  set sourceDeviceId(String? sourceDeviceId) =>
      _$this._sourceDeviceId = sourceDeviceId;

  String? _sourceMutationId;
  String? get sourceMutationId => _$this._sourceMutationId;
  set sourceMutationId(String? sourceMutationId) =>
      _$this._sourceMutationId = sourceMutationId;

  int? _candidateVersion;
  int? get candidateVersion => _$this._candidateVersion;
  set candidateVersion(int? candidateVersion) =>
      _$this._candidateVersion = candidateVersion;

  CategoryConflictActionEnum? _action;
  CategoryConflictActionEnum? get action => _$this._action;
  set action(CategoryConflictActionEnum? action) => _$this._action = action;

  CategoryConflictLocalPayloadBuilder? _localPayload;
  CategoryConflictLocalPayloadBuilder get localPayload =>
      _$this._localPayload ??= CategoryConflictLocalPayloadBuilder();
  set localPayload(CategoryConflictLocalPayloadBuilder? localPayload) =>
      _$this._localPayload = localPayload;

  DateTime? _localUpdatedAt;
  DateTime? get localUpdatedAt => _$this._localUpdatedAt;
  set localUpdatedAt(DateTime? localUpdatedAt) =>
      _$this._localUpdatedAt = localUpdatedAt;

  CategoryBuilder? _cloudSnapshot;
  CategoryBuilder get cloudSnapshot =>
      _$this._cloudSnapshot ??= CategoryBuilder();
  set cloudSnapshot(CategoryBuilder? cloudSnapshot) =>
      _$this._cloudSnapshot = cloudSnapshot;

  CategoryConflictStatusEnum? _status;
  CategoryConflictStatusEnum? get status => _$this._status;
  set status(CategoryConflictStatusEnum? status) => _$this._status = status;

  CategoryConflictResolutionEnum? _resolution;
  CategoryConflictResolutionEnum? get resolution => _$this._resolution;
  set resolution(CategoryConflictResolutionEnum? resolution) =>
      _$this._resolution = resolution;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _resolvedAt;
  DateTime? get resolvedAt => _$this._resolvedAt;
  set resolvedAt(DateTime? resolvedAt) => _$this._resolvedAt = resolvedAt;

  CategoryConflictBuilder() {
    CategoryConflict._defaults(this);
  }

  CategoryConflictBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _categoryId = $v.categoryId;
      _templateKey = $v.templateKey;
      _sourceDeviceId = $v.sourceDeviceId;
      _sourceMutationId = $v.sourceMutationId;
      _candidateVersion = $v.candidateVersion;
      _action = $v.action;
      _localPayload = $v.localPayload?.toBuilder();
      _localUpdatedAt = $v.localUpdatedAt;
      _cloudSnapshot = $v.cloudSnapshot.toBuilder();
      _status = $v.status;
      _resolution = $v.resolution;
      _createdAt = $v.createdAt;
      _resolvedAt = $v.resolvedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CategoryConflict other) {
    _$v = other as _$CategoryConflict;
  }

  @override
  void update(void Function(CategoryConflictBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CategoryConflict build() => _build();

  _$CategoryConflict _build() {
    _$CategoryConflict _$result;
    try {
      _$result = _$v ??
          _$CategoryConflict._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'CategoryConflict', 'id'),
            categoryId: BuiltValueNullFieldError.checkNotNull(
                categoryId, r'CategoryConflict', 'categoryId'),
            templateKey: BuiltValueNullFieldError.checkNotNull(
                templateKey, r'CategoryConflict', 'templateKey'),
            sourceDeviceId: BuiltValueNullFieldError.checkNotNull(
                sourceDeviceId, r'CategoryConflict', 'sourceDeviceId'),
            sourceMutationId: BuiltValueNullFieldError.checkNotNull(
                sourceMutationId, r'CategoryConflict', 'sourceMutationId'),
            candidateVersion: BuiltValueNullFieldError.checkNotNull(
                candidateVersion, r'CategoryConflict', 'candidateVersion'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'CategoryConflict', 'action'),
            localPayload: _localPayload?.build(),
            localUpdatedAt: BuiltValueNullFieldError.checkNotNull(
                localUpdatedAt, r'CategoryConflict', 'localUpdatedAt'),
            cloudSnapshot: cloudSnapshot.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'CategoryConflict', 'status'),
            resolution: resolution,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'CategoryConflict', 'createdAt'),
            resolvedAt: resolvedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'localPayload';
        _localPayload?.build();

        _$failedField = 'cloudSnapshot';
        cloudSnapshot.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CategoryConflict', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
