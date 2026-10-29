// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_admin_banner_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateAdminBannerRequestSlotEnum
    _$createAdminBannerRequestSlotEnum_fitnessPlanLibrary =
    const CreateAdminBannerRequestSlotEnum._('fitnessPlanLibrary');
const CreateAdminBannerRequestSlotEnum
    _$createAdminBannerRequestSlotEnum_fitnessTemplateLibrary =
    const CreateAdminBannerRequestSlotEnum._('fitnessTemplateLibrary');

CreateAdminBannerRequestSlotEnum _$createAdminBannerRequestSlotEnumValueOf(
    String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$createAdminBannerRequestSlotEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$createAdminBannerRequestSlotEnum_fitnessTemplateLibrary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateAdminBannerRequestSlotEnum>
    _$createAdminBannerRequestSlotEnumValues = BuiltSet<
        CreateAdminBannerRequestSlotEnum>(const <CreateAdminBannerRequestSlotEnum>[
  _$createAdminBannerRequestSlotEnum_fitnessPlanLibrary,
  _$createAdminBannerRequestSlotEnum_fitnessTemplateLibrary,
]);

const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_fitnessPlanLibrary =
    const CreateAdminBannerRequestTargetEnum._('fitnessPlanLibrary');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_fitnessTemplateLibrary =
    const CreateAdminBannerRequestTargetEnum._('fitnessTemplateLibrary');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_fitnessExercises =
    const CreateAdminBannerRequestTargetEnum._('fitnessExercises');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_fitnessPlans =
    const CreateAdminBannerRequestTargetEnum._('fitnessPlans');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_fitnessTemplates =
    const CreateAdminBannerRequestTargetEnum._('fitnessTemplates');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_officialPlan =
    const CreateAdminBannerRequestTargetEnum._('officialPlan');
const CreateAdminBannerRequestTargetEnum
    _$createAdminBannerRequestTargetEnum_officialTemplate =
    const CreateAdminBannerRequestTargetEnum._('officialTemplate');

CreateAdminBannerRequestTargetEnum _$createAdminBannerRequestTargetEnumValueOf(
    String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$createAdminBannerRequestTargetEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$createAdminBannerRequestTargetEnum_fitnessTemplateLibrary;
    case 'fitnessExercises':
      return _$createAdminBannerRequestTargetEnum_fitnessExercises;
    case 'fitnessPlans':
      return _$createAdminBannerRequestTargetEnum_fitnessPlans;
    case 'fitnessTemplates':
      return _$createAdminBannerRequestTargetEnum_fitnessTemplates;
    case 'officialPlan':
      return _$createAdminBannerRequestTargetEnum_officialPlan;
    case 'officialTemplate':
      return _$createAdminBannerRequestTargetEnum_officialTemplate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateAdminBannerRequestTargetEnum>
    _$createAdminBannerRequestTargetEnumValues = BuiltSet<
        CreateAdminBannerRequestTargetEnum>(const <CreateAdminBannerRequestTargetEnum>[
  _$createAdminBannerRequestTargetEnum_fitnessPlanLibrary,
  _$createAdminBannerRequestTargetEnum_fitnessTemplateLibrary,
  _$createAdminBannerRequestTargetEnum_fitnessExercises,
  _$createAdminBannerRequestTargetEnum_fitnessPlans,
  _$createAdminBannerRequestTargetEnum_fitnessTemplates,
  _$createAdminBannerRequestTargetEnum_officialPlan,
  _$createAdminBannerRequestTargetEnum_officialTemplate,
]);

Serializer<CreateAdminBannerRequestSlotEnum>
    _$createAdminBannerRequestSlotEnumSerializer =
    _$CreateAdminBannerRequestSlotEnumSerializer();
Serializer<CreateAdminBannerRequestTargetEnum>
    _$createAdminBannerRequestTargetEnumSerializer =
    _$CreateAdminBannerRequestTargetEnumSerializer();

class _$CreateAdminBannerRequestSlotEnumSerializer
    implements PrimitiveSerializer<CreateAdminBannerRequestSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateAdminBannerRequestSlotEnum];
  @override
  final String wireName = 'CreateAdminBannerRequestSlotEnum';

  @override
  Object serialize(
          Serializers serializers, CreateAdminBannerRequestSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateAdminBannerRequestSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateAdminBannerRequestSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateAdminBannerRequestTargetEnumSerializer
    implements PrimitiveSerializer<CreateAdminBannerRequestTargetEnum> {
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
  final Iterable<Type> types = const <Type>[CreateAdminBannerRequestTargetEnum];
  @override
  final String wireName = 'CreateAdminBannerRequestTargetEnum';

  @override
  Object serialize(
          Serializers serializers, CreateAdminBannerRequestTargetEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateAdminBannerRequestTargetEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateAdminBannerRequestTargetEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateAdminBannerRequest extends CreateAdminBannerRequest {
  @override
  final CreateAdminBannerRequestSlotEnum slot;
  @override
  final String imageId;
  @override
  final CreateAdminBannerRequestTargetEnum target;
  @override
  final String? targetId;
  @override
  final int sortOrder;

  factory _$CreateAdminBannerRequest(
          [void Function(CreateAdminBannerRequestBuilder)? updates]) =>
      (CreateAdminBannerRequestBuilder()..update(updates))._build();

  _$CreateAdminBannerRequest._(
      {required this.slot,
      required this.imageId,
      required this.target,
      this.targetId,
      required this.sortOrder})
      : super._();
  @override
  CreateAdminBannerRequest rebuild(
          void Function(CreateAdminBannerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateAdminBannerRequestBuilder toBuilder() =>
      CreateAdminBannerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAdminBannerRequest &&
        slot == other.slot &&
        imageId == other.imageId &&
        target == other.target &&
        targetId == other.targetId &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, imageId.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAdminBannerRequest')
          ..add('slot', slot)
          ..add('imageId', imageId)
          ..add('target', target)
          ..add('targetId', targetId)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class CreateAdminBannerRequestBuilder
    implements
        Builder<CreateAdminBannerRequest, CreateAdminBannerRequestBuilder> {
  _$CreateAdminBannerRequest? _$v;

  CreateAdminBannerRequestSlotEnum? _slot;
  CreateAdminBannerRequestSlotEnum? get slot => _$this._slot;
  set slot(CreateAdminBannerRequestSlotEnum? slot) => _$this._slot = slot;

  String? _imageId;
  String? get imageId => _$this._imageId;
  set imageId(String? imageId) => _$this._imageId = imageId;

  CreateAdminBannerRequestTargetEnum? _target;
  CreateAdminBannerRequestTargetEnum? get target => _$this._target;
  set target(CreateAdminBannerRequestTargetEnum? target) =>
      _$this._target = target;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  CreateAdminBannerRequestBuilder() {
    CreateAdminBannerRequest._defaults(this);
  }

  CreateAdminBannerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _imageId = $v.imageId;
      _target = $v.target;
      _targetId = $v.targetId;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAdminBannerRequest other) {
    _$v = other as _$CreateAdminBannerRequest;
  }

  @override
  void update(void Function(CreateAdminBannerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAdminBannerRequest build() => _build();

  _$CreateAdminBannerRequest _build() {
    final _$result = _$v ??
        _$CreateAdminBannerRequest._(
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'CreateAdminBannerRequest', 'slot'),
          imageId: BuiltValueNullFieldError.checkNotNull(
              imageId, r'CreateAdminBannerRequest', 'imageId'),
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'CreateAdminBannerRequest', 'target'),
          targetId: targetId,
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'CreateAdminBannerRequest', 'sortOrder'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
