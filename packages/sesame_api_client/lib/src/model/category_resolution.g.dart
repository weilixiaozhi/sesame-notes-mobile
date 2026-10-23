// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_resolution.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CategoryResolutionResolutionEnum
    _$categoryResolutionResolutionEnum_cloud =
    const CategoryResolutionResolutionEnum._('cloud');
const CategoryResolutionResolutionEnum
    _$categoryResolutionResolutionEnum_local =
    const CategoryResolutionResolutionEnum._('local');

CategoryResolutionResolutionEnum _$categoryResolutionResolutionEnumValueOf(
    String name) {
  switch (name) {
    case 'cloud':
      return _$categoryResolutionResolutionEnum_cloud;
    case 'local':
      return _$categoryResolutionResolutionEnum_local;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CategoryResolutionResolutionEnum>
    _$categoryResolutionResolutionEnumValues = BuiltSet<
        CategoryResolutionResolutionEnum>(const <CategoryResolutionResolutionEnum>[
  _$categoryResolutionResolutionEnum_cloud,
  _$categoryResolutionResolutionEnum_local,
]);

Serializer<CategoryResolutionResolutionEnum>
    _$categoryResolutionResolutionEnumSerializer =
    _$CategoryResolutionResolutionEnumSerializer();

class _$CategoryResolutionResolutionEnumSerializer
    implements PrimitiveSerializer<CategoryResolutionResolutionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'cloud': 'cloud',
    'local': 'local',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'cloud': 'cloud',
    'local': 'local',
  };

  @override
  final Iterable<Type> types = const <Type>[CategoryResolutionResolutionEnum];
  @override
  final String wireName = 'CategoryResolutionResolutionEnum';

  @override
  Object serialize(
          Serializers serializers, CategoryResolutionResolutionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CategoryResolutionResolutionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CategoryResolutionResolutionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CategoryResolution extends CategoryResolution {
  @override
  final String conflictId;
  @override
  final int candidateVersion;
  @override
  final String sourceDeviceId;
  @override
  final String sourceMutationId;
  @override
  final CategoryResolutionResolutionEnum resolution;
  @override
  final Category categoryState;

  factory _$CategoryResolution(
          [void Function(CategoryResolutionBuilder)? updates]) =>
      (CategoryResolutionBuilder()..update(updates))._build();

  _$CategoryResolution._(
      {required this.conflictId,
      required this.candidateVersion,
      required this.sourceDeviceId,
      required this.sourceMutationId,
      required this.resolution,
      required this.categoryState})
      : super._();
  @override
  CategoryResolution rebuild(
          void Function(CategoryResolutionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CategoryResolutionBuilder toBuilder() =>
      CategoryResolutionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CategoryResolution &&
        conflictId == other.conflictId &&
        candidateVersion == other.candidateVersion &&
        sourceDeviceId == other.sourceDeviceId &&
        sourceMutationId == other.sourceMutationId &&
        resolution == other.resolution &&
        categoryState == other.categoryState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, conflictId.hashCode);
    _$hash = $jc(_$hash, candidateVersion.hashCode);
    _$hash = $jc(_$hash, sourceDeviceId.hashCode);
    _$hash = $jc(_$hash, sourceMutationId.hashCode);
    _$hash = $jc(_$hash, resolution.hashCode);
    _$hash = $jc(_$hash, categoryState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CategoryResolution')
          ..add('conflictId', conflictId)
          ..add('candidateVersion', candidateVersion)
          ..add('sourceDeviceId', sourceDeviceId)
          ..add('sourceMutationId', sourceMutationId)
          ..add('resolution', resolution)
          ..add('categoryState', categoryState))
        .toString();
  }
}

class CategoryResolutionBuilder
    implements Builder<CategoryResolution, CategoryResolutionBuilder> {
  _$CategoryResolution? _$v;

  String? _conflictId;
  String? get conflictId => _$this._conflictId;
  set conflictId(String? conflictId) => _$this._conflictId = conflictId;

  int? _candidateVersion;
  int? get candidateVersion => _$this._candidateVersion;
  set candidateVersion(int? candidateVersion) =>
      _$this._candidateVersion = candidateVersion;

  String? _sourceDeviceId;
  String? get sourceDeviceId => _$this._sourceDeviceId;
  set sourceDeviceId(String? sourceDeviceId) =>
      _$this._sourceDeviceId = sourceDeviceId;

  String? _sourceMutationId;
  String? get sourceMutationId => _$this._sourceMutationId;
  set sourceMutationId(String? sourceMutationId) =>
      _$this._sourceMutationId = sourceMutationId;

  CategoryResolutionResolutionEnum? _resolution;
  CategoryResolutionResolutionEnum? get resolution => _$this._resolution;
  set resolution(CategoryResolutionResolutionEnum? resolution) =>
      _$this._resolution = resolution;

  CategoryBuilder? _categoryState;
  CategoryBuilder get categoryState =>
      _$this._categoryState ??= CategoryBuilder();
  set categoryState(CategoryBuilder? categoryState) =>
      _$this._categoryState = categoryState;

  CategoryResolutionBuilder() {
    CategoryResolution._defaults(this);
  }

  CategoryResolutionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _conflictId = $v.conflictId;
      _candidateVersion = $v.candidateVersion;
      _sourceDeviceId = $v.sourceDeviceId;
      _sourceMutationId = $v.sourceMutationId;
      _resolution = $v.resolution;
      _categoryState = $v.categoryState.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CategoryResolution other) {
    _$v = other as _$CategoryResolution;
  }

  @override
  void update(void Function(CategoryResolutionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CategoryResolution build() => _build();

  _$CategoryResolution _build() {
    _$CategoryResolution _$result;
    try {
      _$result = _$v ??
          _$CategoryResolution._(
            conflictId: BuiltValueNullFieldError.checkNotNull(
                conflictId, r'CategoryResolution', 'conflictId'),
            candidateVersion: BuiltValueNullFieldError.checkNotNull(
                candidateVersion, r'CategoryResolution', 'candidateVersion'),
            sourceDeviceId: BuiltValueNullFieldError.checkNotNull(
                sourceDeviceId, r'CategoryResolution', 'sourceDeviceId'),
            sourceMutationId: BuiltValueNullFieldError.checkNotNull(
                sourceMutationId, r'CategoryResolution', 'sourceMutationId'),
            resolution: BuiltValueNullFieldError.checkNotNull(
                resolution, r'CategoryResolution', 'resolution'),
            categoryState: categoryState.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryState';
        categoryState.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CategoryResolution', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
