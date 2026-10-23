// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of3.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum_fitnessPreferences =
    const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
        ._('fitnessPreferences');

GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessPreferences':
      return _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum_fitnessPreferences;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>(const <GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>[
  _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum_fitnessPreferences,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessPreferences': 'fitness_preferences',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_preferences': 'fitnessPreferences',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
    extends GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3 {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
      entityType;
  @override
  final PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload payload;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3._(
      {required this.id, required this.entityType, required this.payload})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3 rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3 &&
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('payload', payload))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum?
      _entityType;
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum?
      get entityType => _$this._entityType;
  set entityType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder() {
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
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
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3 build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3',
                'id'),
            entityType: BuiltValueNullFieldError.checkNotNull(
                entityType,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3',
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3',
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
