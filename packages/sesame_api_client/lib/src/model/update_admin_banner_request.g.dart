// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_admin_banner_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const UpdateAdminBannerRequestSlotEnum
    _$updateAdminBannerRequestSlotEnum_fitnessPlanLibrary =
    const UpdateAdminBannerRequestSlotEnum._('fitnessPlanLibrary');
const UpdateAdminBannerRequestSlotEnum
    _$updateAdminBannerRequestSlotEnum_fitnessTemplateLibrary =
    const UpdateAdminBannerRequestSlotEnum._('fitnessTemplateLibrary');

UpdateAdminBannerRequestSlotEnum _$updateAdminBannerRequestSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$updateAdminBannerRequestSlotEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$updateAdminBannerRequestSlotEnum_fitnessTemplateLibrary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<UpdateAdminBannerRequestSlotEnum>
    _$updateAdminBannerRequestSlotEnumValues = BuiltSet<
        UpdateAdminBannerRequestSlotEnum>(const <UpdateAdminBannerRequestSlotEnum>[
  _$updateAdminBannerRequestSlotEnum_fitnessPlanLibrary,
  _$updateAdminBannerRequestSlotEnum_fitnessTemplateLibrary,
]);

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
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_officialPlan =
    const UpdateAdminBannerRequestTargetEnum._('officialPlan');
const UpdateAdminBannerRequestTargetEnum
    _$updateAdminBannerRequestTargetEnum_officialTemplate =
    const UpdateAdminBannerRequestTargetEnum._('officialTemplate');

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
    case 'officialPlan':
      return _$updateAdminBannerRequestTargetEnum_officialPlan;
    case 'officialTemplate':
      return _$updateAdminBannerRequestTargetEnum_officialTemplate;
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
  _$updateAdminBannerRequestTargetEnum_officialPlan,
  _$updateAdminBannerRequestTargetEnum_officialTemplate,
]);

Serializer<UpdateAdminBannerRequestSlotEnum>
    _$updateAdminBannerRequestSlotEnumSerializer =
    _$UpdateAdminBannerRequestSlotEnumSerializer();
Serializer<UpdateAdminBannerRequestTargetEnum>
    _$updateAdminBannerRequestTargetEnumSerializer =
    _$UpdateAdminBannerRequestTargetEnumSerializer();

class _$UpdateAdminBannerRequestSlotEnumSerializer
    implements PrimitiveSerializer<UpdateAdminBannerRequestSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
  };

  @override
  final Iterable<Type> types = const <Type>[UpdateAdminBannerRequestSlotEnum];
  @override
  final String wireName = 'UpdateAdminBannerRequestSlotEnum';

  @override
  Object serialize(
          Serializers serializers, UpdateAdminBannerRequestSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  UpdateAdminBannerRequestSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      UpdateAdminBannerRequestSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$UpdateAdminBannerRequestTargetEnumSerializer
    implements PrimitiveSerializer<UpdateAdminBannerRequestTargetEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
    'fitnessExercises': 'fitness-exercises',
    'fitnessPlans': 'fitness-plans',
    'fitnessTemplates': 'fitness-templates',
    'officialPlan': 'official-plan',
    'officialTemplate': 'official-template',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
    'fitness-exercises': 'fitnessExercises',
    'fitness-plans': 'fitnessPlans',
    'fitness-templates': 'fitnessTemplates',
    'official-plan': 'officialPlan',
    'official-template': 'officialTemplate',
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
  final UpdateAdminBannerRequestSlotEnum slot;
  @override
  final String imageId;
  @override
  final UpdateAdminBannerRequestTargetEnum target;
  @override
  final String? targetId;
  @override
  final int sortOrder;
  @override
  final int version;

  factory _$UpdateAdminBannerRequest(
          [void Function(UpdateAdminBannerRequestBuilder)? updates]) =>
      (UpdateAdminBannerRequestBuilder()..update(updates))._build();

  _$UpdateAdminBannerRequest._(
      {required this.slot,
      required this.imageId,
      required this.target,
      this.targetId,
      required this.sortOrder,
      required this.version})
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
        slot == other.slot &&
        imageId == other.imageId &&
        target == other.target &&
        targetId == other.targetId &&
        sortOrder == other.sortOrder &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, imageId.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateAdminBannerRequest')
          ..add('slot', slot)
          ..add('imageId', imageId)
          ..add('target', target)
          ..add('targetId', targetId)
          ..add('sortOrder', sortOrder)
          ..add('version', version))
        .toString();
  }
}

class UpdateAdminBannerRequestBuilder
    implements
        Builder<UpdateAdminBannerRequest, UpdateAdminBannerRequestBuilder> {
  _$UpdateAdminBannerRequest? _$v;

  UpdateAdminBannerRequestSlotEnum? _slot;
  UpdateAdminBannerRequestSlotEnum? get slot => _$this._slot;
  set slot(UpdateAdminBannerRequestSlotEnum? slot) => _$this._slot = slot;

  String? _imageId;
  String? get imageId => _$this._imageId;
  set imageId(String? imageId) => _$this._imageId = imageId;

  UpdateAdminBannerRequestTargetEnum? _target;
  UpdateAdminBannerRequestTargetEnum? get target => _$this._target;
  set target(UpdateAdminBannerRequestTargetEnum? target) =>
      _$this._target = target;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  UpdateAdminBannerRequestBuilder() {
    UpdateAdminBannerRequest._defaults(this);
  }

  UpdateAdminBannerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _imageId = $v.imageId;
      _target = $v.target;
      _targetId = $v.targetId;
      _sortOrder = $v.sortOrder;
      _version = $v.version;
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
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'UpdateAdminBannerRequest', 'slot'),
          imageId: BuiltValueNullFieldError.checkNotNull(
              imageId, r'UpdateAdminBannerRequest', 'imageId'),
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'UpdateAdminBannerRequest', 'target'),
          targetId: targetId,
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'UpdateAdminBannerRequest', 'sortOrder'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'UpdateAdminBannerRequest', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
