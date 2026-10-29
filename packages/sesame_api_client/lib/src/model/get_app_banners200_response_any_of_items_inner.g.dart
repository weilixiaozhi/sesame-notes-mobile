// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response_any_of_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
    _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessPlanLibrary =
    const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum._(
        'fitnessPlanLibrary');
const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
    _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessTemplateLibrary =
    const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum._(
        'fitnessTemplateLibrary');

GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
    _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessTemplateLibrary;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAppBanners200ResponseAnyOfItemsInnerSlotEnum>
    _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumValues = BuiltSet<
        GetAppBanners200ResponseAnyOfItemsInnerSlotEnum>(const <GetAppBanners200ResponseAnyOfItemsInnerSlotEnum>[
  _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessPlanLibrary,
  _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessTemplateLibrary,
]);

const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlanLibrary =
    const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._(
        'fitnessPlanLibrary');
const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplateLibrary =
    const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._(
        'fitnessTemplateLibrary');
const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessExercises =
    const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._(
        'fitnessExercises');
const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlans =
    const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._('fitnessPlans');
const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplates =
    const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._(
        'fitnessTemplates');

GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumValueOf(String name) {
  switch (name) {
    case 'fitnessPlanLibrary':
      return _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlanLibrary;
    case 'fitnessTemplateLibrary':
      return _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplateLibrary;
    case 'fitnessExercises':
      return _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessExercises;
    case 'fitnessPlans':
      return _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlans;
    case 'fitnessTemplates':
      return _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplates;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumValues = BuiltSet<
        GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>(const <GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>[
  _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlanLibrary,
  _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplateLibrary,
  _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessExercises,
  _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlans,
  _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplates,
]);

Serializer<GetAppBanners200ResponseAnyOfItemsInnerSlotEnum>
    _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumSerializer =
    _$GetAppBanners200ResponseAnyOfItemsInnerSlotEnumSerializer();
Serializer<GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>
    _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumSerializer =
    _$GetAppBanners200ResponseAnyOfItemsInnerTargetEnumSerializer();

class _$GetAppBanners200ResponseAnyOfItemsInnerSlotEnumSerializer
    implements
        PrimitiveSerializer<GetAppBanners200ResponseAnyOfItemsInnerSlotEnum> {
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
    GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
  ];
  @override
  final String wireName = 'GetAppBanners200ResponseAnyOfItemsInnerSlotEnum';

  @override
  Object serialize(Serializers serializers,
          GetAppBanners200ResponseAnyOfItemsInnerSlotEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAppBanners200ResponseAnyOfItemsInnerSlotEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAppBanners200ResponseAnyOfItemsInnerSlotEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAppBanners200ResponseAnyOfItemsInnerTargetEnumSerializer
    implements
        PrimitiveSerializer<GetAppBanners200ResponseAnyOfItemsInnerTargetEnum> {
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
  final Iterable<Type> types = const <Type>[
    GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
  ];
  @override
  final String wireName = 'GetAppBanners200ResponseAnyOfItemsInnerTargetEnum';

  @override
  Object serialize(Serializers serializers,
          GetAppBanners200ResponseAnyOfItemsInnerTargetEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAppBanners200ResponseAnyOfItemsInnerTargetEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAppBanners200ResponseAnyOfItemsInnerTargetEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAppBanners200ResponseAnyOfItemsInner
    extends GetAppBanners200ResponseAnyOfItemsInner {
  @override
  final GetAppBanners200ResponseAnyOfItemsInnerSlotEnum slot;
  @override
  final String? imagePath;
  @override
  final GetAppBanners200ResponseAnyOfItemsInnerTargetEnum target;
  @override
  final bool isEnabled;
  @override
  final int version;
  @override
  final DateTime? updatedAt;

  factory _$GetAppBanners200ResponseAnyOfItemsInner(
          [void Function(GetAppBanners200ResponseAnyOfItemsInnerBuilder)?
              updates]) =>
      (GetAppBanners200ResponseAnyOfItemsInnerBuilder()..update(updates))
          ._build();

  _$GetAppBanners200ResponseAnyOfItemsInner._(
      {required this.slot,
      this.imagePath,
      required this.target,
      required this.isEnabled,
      required this.version,
      this.updatedAt})
      : super._();
  @override
  GetAppBanners200ResponseAnyOfItemsInner rebuild(
          void Function(GetAppBanners200ResponseAnyOfItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseAnyOfItemsInnerBuilder toBuilder() =>
      GetAppBanners200ResponseAnyOfItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200ResponseAnyOfItemsInner &&
        slot == other.slot &&
        imagePath == other.imagePath &&
        target == other.target &&
        isEnabled == other.isEnabled &&
        version == other.version &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, slot.hashCode);
    _$hash = $jc(_$hash, imagePath.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAppBanners200ResponseAnyOfItemsInner')
          ..add('slot', slot)
          ..add('imagePath', imagePath)
          ..add('target', target)
          ..add('isEnabled', isEnabled)
          ..add('version', version)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GetAppBanners200ResponseAnyOfItemsInnerBuilder
    implements
        Builder<GetAppBanners200ResponseAnyOfItemsInner,
            GetAppBanners200ResponseAnyOfItemsInnerBuilder> {
  _$GetAppBanners200ResponseAnyOfItemsInner? _$v;

  GetAppBanners200ResponseAnyOfItemsInnerSlotEnum? _slot;
  GetAppBanners200ResponseAnyOfItemsInnerSlotEnum? get slot => _$this._slot;
  set slot(GetAppBanners200ResponseAnyOfItemsInnerSlotEnum? slot) =>
      _$this._slot = slot;

  String? _imagePath;
  String? get imagePath => _$this._imagePath;
  set imagePath(String? imagePath) => _$this._imagePath = imagePath;

  GetAppBanners200ResponseAnyOfItemsInnerTargetEnum? _target;
  GetAppBanners200ResponseAnyOfItemsInnerTargetEnum? get target =>
      _$this._target;
  set target(GetAppBanners200ResponseAnyOfItemsInnerTargetEnum? target) =>
      _$this._target = target;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GetAppBanners200ResponseAnyOfItemsInnerBuilder() {
    GetAppBanners200ResponseAnyOfItemsInner._defaults(this);
  }

  GetAppBanners200ResponseAnyOfItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _slot = $v.slot;
      _imagePath = $v.imagePath;
      _target = $v.target;
      _isEnabled = $v.isEnabled;
      _version = $v.version;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200ResponseAnyOfItemsInner other) {
    _$v = other as _$GetAppBanners200ResponseAnyOfItemsInner;
  }

  @override
  void update(
      void Function(GetAppBanners200ResponseAnyOfItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200ResponseAnyOfItemsInner build() => _build();

  _$GetAppBanners200ResponseAnyOfItemsInner _build() {
    final _$result = _$v ??
        _$GetAppBanners200ResponseAnyOfItemsInner._(
          slot: BuiltValueNullFieldError.checkNotNull(
              slot, r'GetAppBanners200ResponseAnyOfItemsInner', 'slot'),
          imagePath: imagePath,
          target: BuiltValueNullFieldError.checkNotNull(
              target, r'GetAppBanners200ResponseAnyOfItemsInner', 'target'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(isEnabled,
              r'GetAppBanners200ResponseAnyOfItemsInner', 'isEnabled'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'GetAppBanners200ResponseAnyOfItemsInner', 'version'),
          updatedAt: updatedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
