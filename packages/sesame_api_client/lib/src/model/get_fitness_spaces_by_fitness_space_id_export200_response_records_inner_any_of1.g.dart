// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum_fitnessPlan =
    const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
        ._('fitnessPlan');

GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPlan':
      return _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum_fitnessPlan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>(const <GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>[
  _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum_fitnessPlan,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPlan': 'fitness_plan',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_plan': 'fitnessPlan',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
    extends GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1 {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
      entityType;
  @override
  final PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload payload;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1._(
      {required this.id, required this.entityType, required this.payload})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1 rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1 &&
        id == other.id &&
        entityType == other.entityType &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('payload', payload))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum?
      _entityType;
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum?
      get entityType => _$this._entityType;
  set entityType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder() {
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _entityType = $v.entityType;
      _payload = $v.payload.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1 build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1',
                'id'),
            entityType: BuiltValueNullFieldError.checkNotNull(
                entityType,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1',
                'entityType'),
            payload: payload.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1',
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
