// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_identity_types200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminIdentityTypes200ResponseItemsInnerValueEnum
    _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_superAdmin =
    const GetAdminIdentityTypes200ResponseItemsInnerValueEnum._('superAdmin');
const GetAdminIdentityTypes200ResponseItemsInnerValueEnum
    _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_standardUser =
    const GetAdminIdentityTypes200ResponseItemsInnerValueEnum._('standardUser');

GetAdminIdentityTypes200ResponseItemsInnerValueEnum
    _$getAdminIdentityTypes200ResponseItemsInnerValueEnumValueOf(String name) {
  switch (name) {
    case 'superAdmin':
      return _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_superAdmin;
    case 'standardUser':
      return _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_standardUser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetAdminIdentityTypes200ResponseItemsInnerValueEnum>
    _$getAdminIdentityTypes200ResponseItemsInnerValueEnumValues = BuiltSet<
        GetAdminIdentityTypes200ResponseItemsInnerValueEnum>(const <GetAdminIdentityTypes200ResponseItemsInnerValueEnum>[
  _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_superAdmin,
  _$getAdminIdentityTypes200ResponseItemsInnerValueEnum_standardUser,
]);

Serializer<GetAdminIdentityTypes200ResponseItemsInnerValueEnum>
    _$getAdminIdentityTypes200ResponseItemsInnerValueEnumSerializer =
    _$GetAdminIdentityTypes200ResponseItemsInnerValueEnumSerializer();

class _$GetAdminIdentityTypes200ResponseItemsInnerValueEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminIdentityTypes200ResponseItemsInnerValueEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'superAdmin': 'super_admin',
    'standardUser': 'standard_user',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'super_admin': 'superAdmin',
    'standard_user': 'standardUser',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetAdminIdentityTypes200ResponseItemsInnerValueEnum
  ];
  @override
  final String wireName = 'GetAdminIdentityTypes200ResponseItemsInnerValueEnum';

  @override
  Object serialize(Serializers serializers,
          GetAdminIdentityTypes200ResponseItemsInnerValueEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminIdentityTypes200ResponseItemsInnerValueEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetAdminIdentityTypes200ResponseItemsInnerValueEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetAdminIdentityTypes200ResponseItemsInner
    extends GetAdminIdentityTypes200ResponseItemsInner {
  @override
  final GetAdminIdentityTypes200ResponseItemsInnerValueEnum value;
  @override
  final String label;

  factory _$GetAdminIdentityTypes200ResponseItemsInner(
          [void Function(GetAdminIdentityTypes200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminIdentityTypes200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$GetAdminIdentityTypes200ResponseItemsInner._(
      {required this.value, required this.label})
      : super._();
  @override
  GetAdminIdentityTypes200ResponseItemsInner rebuild(
          void Function(GetAdminIdentityTypes200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminIdentityTypes200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminIdentityTypes200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminIdentityTypes200ResponseItemsInner &&
        value == other.value &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminIdentityTypes200ResponseItemsInner')
          ..add('value', value)
          ..add('label', label))
        .toString();
  }
}

class GetAdminIdentityTypes200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminIdentityTypes200ResponseItemsInner,
            GetAdminIdentityTypes200ResponseItemsInnerBuilder> {
  _$GetAdminIdentityTypes200ResponseItemsInner? _$v;

  GetAdminIdentityTypes200ResponseItemsInnerValueEnum? _value;
  GetAdminIdentityTypes200ResponseItemsInnerValueEnum? get value =>
      _$this._value;
  set value(GetAdminIdentityTypes200ResponseItemsInnerValueEnum? value) =>
      _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  GetAdminIdentityTypes200ResponseItemsInnerBuilder() {
    GetAdminIdentityTypes200ResponseItemsInner._defaults(this);
  }

  GetAdminIdentityTypes200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminIdentityTypes200ResponseItemsInner other) {
    _$v = other as _$GetAdminIdentityTypes200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminIdentityTypes200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminIdentityTypes200ResponseItemsInner build() => _build();

  _$GetAdminIdentityTypes200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetAdminIdentityTypes200ResponseItemsInner._(
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'GetAdminIdentityTypes200ResponseItemsInner', 'value'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'GetAdminIdentityTypes200ResponseItemsInner', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
