// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum_fitnessPreferences =
    const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
        ._('fitnessPreferences');

GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPreferences':
      return _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum_fitnessPreferences;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>(const <GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>[
  _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum_fitnessPreferences,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPreferences': 'fitness_preferences',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_preferences': 'fitnessPreferences',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner
    extends GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner {
  @override
  final AnyOf anyOf;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner._(
      {required this.anyOf})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner &&
        anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf,
              r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner',
              'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
