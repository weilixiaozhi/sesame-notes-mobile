// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of2.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum_fitnessWorkout =
    const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
        ._('fitnessWorkout');

GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessWorkout':
      return _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum_fitnessWorkout;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum>(const <GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum>[
  _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum_fitnessWorkout,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessWorkout': 'fitness_workout',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_workout': 'fitnessWorkout',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
    extends GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2 {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum
      entityType;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload payload;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2._(
      {required this.id, required this.entityType, required this.payload})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2 rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2 &&
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('payload', payload))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum?
      _entityType;
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum?
      get entityType => _$this._entityType;
  set entityType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2EntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder() {
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder
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
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2 build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2',
                'id'),
            entityType: BuiltValueNullFieldError.checkNotNull(
                entityType,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2',
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2',
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
