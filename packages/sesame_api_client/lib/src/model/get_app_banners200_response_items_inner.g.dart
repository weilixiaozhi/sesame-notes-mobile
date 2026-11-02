// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAppBanners200ResponseItemsInnerSlotEnum
    _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessPlanLibrary =
    const GetAppBanners200ResponseItemsInnerSlotEnum._('fitnessPlanLibrary');
const GetAppBanners200ResponseItemsInnerSlotEnum
    _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary =
    const GetAppBanners200ResponseItemsInnerSlotEnum._(
        'fitnessTemplateLibrary');

GetAppBanners200ResponseItemsInnerSlotEnum
    _$getAppBanners200ResponseItemsInnerSlotEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAppBanners200ResponseItemsInnerSlotEnum>
    _$getAppBanners200ResponseItemsInnerSlotEnumValues = BuiltSet<
        GetAppBanners200ResponseItemsInnerSlotEnum>(const <GetAppBanners200ResponseItemsInnerSlotEnum>[
  _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessPlanLibrary,
  _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary,
]);

const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlanLibrary =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('fitnessPlanLibrary');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplateLibrary =
    const GetAppBanners200ResponseItemsInnerTargetEnum._(
        'fitnessTemplateLibrary');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessExercises =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('fitnessExercises');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlans =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('fitnessPlans');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplates =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('fitnessTemplates');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_officialPlan =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('officialPlan');
const GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnum_officialTemplate =
    const GetAppBanners200ResponseItemsInnerTargetEnum._('officialTemplate');

GetAppBanners200ResponseItemsInnerTargetEnum
    _$getAppBanners200ResponseItemsInnerTargetEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplateLibrary;
    case 'fitnessExercises':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessExercises;
    case 'fitnessPlans':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlans;
    case 'fitnessTemplates':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplates;
    case 'officialPlan':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_officialPlan;
    case 'officialTemplate':
      return _$getAppBanners200ResponseItemsInnerTargetEnum_officialTemplate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAppBanners200ResponseItemsInnerTargetEnum>
    _$getAppBanners200ResponseItemsInnerTargetEnumValues = BuiltSet<
        GetAppBanners200ResponseItemsInnerTargetEnum>(const <GetAppBanners200ResponseItemsInnerTargetEnum>[
  _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlanLibrary,
  _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplateLibrary,
  _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessExercises,
  _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlans,
  _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplates,
  _$getAppBanners200ResponseItemsInnerTargetEnum_officialPlan,
  _$getAppBanners200ResponseItemsInnerTargetEnum_officialTemplate,
]);

Serializer<GetAppBanners200ResponseItemsInnerSlotEnum>
    _$getAppBanners200ResponseItemsInnerSlotEnumSerializer =
    _$GetAppBanners200ResponseItemsInnerSlotEnumSerializer();
Serializer<GetAppBanners200ResponseItemsInnerTargetEnum>
    _$getAppBanners200ResponseItemsInnerTargetEnumSerializer =
    _$GetAppBanners200ResponseItemsInnerTargetEnumSerializer();

class _$GetAppBanners200ResponseItemsInnerSlotEnumSerializer
    implements PrimitiveSerializer<GetAppBanners200ResponseItemsInnerSlotEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlanLibrary': 'fitness-plan-library',
    'fitnessTemplateLibrary': 'fitness-template-library',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness-plan-library': 'fitnessPlanLibrary',
    'fitness-template-library': 'fitnessTemplateLibrary',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAppBanners200ResponseItemsInnerSlotEnum
  ];
  @override
  final String wireName = 'GetAppBanners200ResponseItemsInnerSlotEnum';

  @override
  Object serialize(Serializers serializers,
          GetAppBanners200ResponseItemsInnerSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAppBanners200ResponseItemsInnerSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAppBanners200ResponseItemsInnerSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAppBanners200ResponseItemsInnerTargetEnumSerializer
    implements
        PrimitiveSerializer<GetAppBanners200ResponseItemsInnerTargetEnum> {
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
  final Iterable<Type> types = const <Type>[
    GetAppBanners200ResponseItemsInnerTargetEnum
  ];
  @override
  final String wireName = 'GetAppBanners200ResponseItemsInnerTargetEnum';

  @override
  Object serialize(Serializers serializers,
          GetAppBanners200ResponseItemsInnerTargetEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAppBanners200ResponseItemsInnerTargetEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAppBanners200ResponseItemsInnerTargetEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAppBanners200ResponseItemsInner
    extends GetAppBanners200ResponseItemsInner {
  @override
  final String id;
  @override
  final GetAppBanners200ResponseItemsInnerSlotEnum slot;
  @override
  final String? imagePath;
  @override
  final GetAppBanners200ResponseItemsInnerTargetEnum target;
  @override
  final String? targetId;
  @override
  final String? targetName;
  @override
  final int version;
  @override
  final int sortOrder;

  factory _$GetAppBanners200ResponseItemsInner(
          [void Function(GetAppBanners200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAppBanners200ResponseItemsInnerBuilder()..update(updates))._build();

  _$GetAppBanners200ResponseItemsInner._(
      {required this.id,
      required this.slot,
      this.imagePath,
      required this.target,
      this.targetId,
      this.targetName,
      required this.version,
      required this.sortOrder})
      : super._();
  @override
  GetAppBanners200ResponseItemsInner rebuild(
          void Function(GetAppBanners200ResponseItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseItemsInnerBuilder toBuilder() =>
      GetAppBanners200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200ResponseItemsInner &&
        id == other.id &&
        slot == other.slot &&
        imagePath == other.imagePath &&
        target == other.target &&
        targetId == other.targetId &&
        targetName == other.targetName &&
        version == other.version &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, imagePath.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, targetName.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAppBanners200ResponseItemsInner')
          ..add('id', id)
          ..add('slot', slot)
          ..add('imagePath', imagePath)
          ..add('target', target)
          ..add('targetId', targetId)
          ..add('targetName', targetName)
          ..add('version', version)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class GetAppBanners200ResponseItemsInnerBuilder
    implements
        Builder<GetAppBanners200ResponseItemsInner,
            GetAppBanners200ResponseItemsInnerBuilder> {
  _$GetAppBanners200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetAppBanners200ResponseItemsInnerSlotEnum? _slot;
  GetAppBanners200ResponseItemsInnerSlotEnum? get slot => _$this._slot;
  set slot(GetAppBanners200ResponseItemsInnerSlotEnum? slot) =>
      _$this._slot = slot;

  String? _imagePath;
  String? get imagePath => _$this._imagePath;
  set imagePath(String? imagePath) => _$this._imagePath = imagePath;

  GetAppBanners200ResponseItemsInnerTargetEnum? _target;
  GetAppBanners200ResponseItemsInnerTargetEnum? get target => _$this._target;
  set target(GetAppBanners200ResponseItemsInnerTargetEnum? target) =>
      _$this._target = target;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _targetName;
  String? get targetName => _$this._targetName;
  set targetName(String? targetName) => _$this._targetName = targetName;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  GetAppBanners200ResponseItemsInnerBuilder() {
    GetAppBanners200ResponseItemsInner._defaults(this);
  }

  GetAppBanners200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _slot = $v.slot;
      _imagePath = $v.imagePath;
      _target = $v.target;
      _targetId = $v.targetId;
      _targetName = $v.targetName;
      _version = $v.version;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200ResponseItemsInner other) {
    _$v = other as _$GetAppBanners200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAppBanners200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200ResponseItemsInner build() => _build();

  _$GetAppBanners200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAppBanners200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetAppBanners200ResponseItemsInner', 'id'),
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'GetAppBanners200ResponseItemsInner', 'slot'),
          imagePath: imagePath,
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'GetAppBanners200ResponseItemsInner', 'target'),
          targetId: targetId,
          targetName: targetName,
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'GetAppBanners200ResponseItemsInner', 'version'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'GetAppBanners200ResponseItemsInner', 'sortOrder'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
