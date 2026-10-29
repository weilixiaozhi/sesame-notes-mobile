// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_admin_banner_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_fitnessPlanLibrary =
    const UpdateAdminBannerRequestTargetEnum._('fitnessPlanLibrary');
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_fitnessTemplateLibrary =
    const UpdateAdminBannerRequestTargetEnum._('fitnessTemplateLibrary');
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_fitnessExercises =
    const UpdateAdminBannerRequestTargetEnum._('fitnessExercises');
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_fitnessPlans =
    const UpdateAdminBannerRequestTargetEnum._('fitnessPlans');
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_fitnessTemplates =
    const UpdateAdminBannerRequestTargetEnum._('fitnessTemplates');

UpdateAdminBannerRequestTargetEnum _$updateAdminBannerRequestTargetEnumValueOf(
    String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$updateAdminBannerRequestTargetEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$updateAdminBannerRequestTargetEnum_fitnessTemplateLibrary;
    case 'fitnessExercises':
      return _$updateAdminBannerRequestTargetEnum_fitnessExercises;
    case 'fitnessPlans':
      return _$updateAdminBannerRequestTargetEnum_fitnessPlans;
    case 'fitnessTemplates':
      return _$updateAdminBannerRequestTargetEnum_fitnessTemplates;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateAdminBannerRequestTargetEnum>
    _$updateAdminBannerRequestTargetEnumValues = BuiltSet<
        UpdateAdminBannerRequestTargetEnum>(const <UpdateAdminBannerRequestTargetEnum>[
  _$updateAdminBannerRequestTargetEnum_fitnessPlanLibrary,
  _$updateAdminBannerRequestTargetEnum_fitnessTemplateLibrary,
  _$updateAdminBannerRequestTargetEnum_fitnessExercises,
  _$updateAdminBannerRequestTargetEnum_fitnessPlans,
  _$updateAdminBannerRequestTargetEnum_fitnessTemplates,
]);

Serializer<UpdateAdminBannerRequestTargetEnum>
    _$updateAdminBannerRequestTargetEnumSerializer =
    _$UpdateAdminBannerRequestTargetEnumSerializer();

class _$UpdateAdminBannerRequestTargetEnumSerializer
    implements PrimitiveSerializer<UpdateAdminBannerRequestTargetEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
    'fitnessExercises': 'fitness-exercises',
    'fitnessPlans': 'fitness-plans',
    'fitnessTemplates': 'fitness-templates',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
    'fitness-exercises': 'fitnessExercises',
    'fitness-plans': 'fitnessPlans',
    'fitness-templates': 'fitnessTemplates',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateAdminBannerRequestTargetEnum];
  @override
  final String wireName = 'UpdateAdminBannerRequestTargetEnum';

  @override
  Object serialize(
          Serializers serializers, UpdateAdminBannerRequestTargetEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateAdminBannerRequestTargetEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateAdminBannerRequestTargetEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateAdminBannerRequest extends UpdateAdminBannerRequest {
  @override
  final int version;
  @override
  final String? imageId;
  @override
  final UpdateAdminBannerRequestTargetEnum target;
  @override
  final bool isEnabled;

  factory _$UpdateAdminBannerRequest(
          [void Function(UpdateAdminBannerRequestBuilder)? updates]) =>
      (UpdateAdminBannerRequestBuilder()..update(updates))._build();

  _$UpdateAdminBannerRequest._(
      {required this.version,
      this.imageId,
      required this.target,
      required this.isEnabled})
      : super._();
  @override
  UpdateAdminBannerRequest rebuild(
          void Function(UpdateAdminBannerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateAdminBannerRequestBuilder toBuilder() =>
      UpdateAdminBannerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateAdminBannerRequest &&
        version == other.version &&
        imageId == other.imageId &&
        target == other.target &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, imageId.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateAdminBannerRequest')
          ..add('version', version)
          ..add('imageId', imageId)
          ..add('target', target)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class UpdateAdminBannerRequestBuilder
    implements
        Builder<UpdateAdminBannerRequest, UpdateAdminBannerRequestBuilder> {
  _$UpdateAdminBannerRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _imageId;
  String? get imageId => _$this._imageId;
  set imageId(String? imageId) => _$this._imageId = imageId;

  UpdateAdminBannerRequestTargetEnum? _target;
  UpdateAdminBannerRequestTargetEnum? get target => _$this._target;
  set target(UpdateAdminBannerRequestTargetEnum? target) =>
      _$this._target = target;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  UpdateAdminBannerRequestBuilder() {
    UpdateAdminBannerRequest._defaults(this);
  }

  UpdateAdminBannerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _imageId = $v.imageId;
      _target = $v.target;
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateAdminBannerRequest other) {
    _$v = other as _$UpdateAdminBannerRequest;
  }

  @override
  void update(void Function(UpdateAdminBannerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateAdminBannerRequest build() => _build();

  _$UpdateAdminBannerRequest _build() {
    final _$result = _$v ??
        _$UpdateAdminBannerRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'UpdateAdminBannerRequest', 'version'),
          imageId: imageId,
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'UpdateAdminBannerRequest', 'target'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(
              isEnabled, r'UpdateAdminBannerRequest', 'isEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
