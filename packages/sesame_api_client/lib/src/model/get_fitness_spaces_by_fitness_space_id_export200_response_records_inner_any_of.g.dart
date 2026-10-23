// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum_fitnessTemplate =
    const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
        ._('fitnessTemplate');

GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'fitnessTemplate':
      return _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum_fitnessTemplate;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>(const <GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>[
  _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum_fitnessTemplate,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>
    _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fitnessTemplate': 'fitness_template',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fitness_template': 'fitnessTemplate',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
    extends GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
      entityType;
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload payload;

  factory _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf._(
      {required this.id, required this.entityType, required this.payload})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf &&
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf')
          ..add('id', id)
          ..add('entityType', entityType)
          ..add('payload', payload))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum?
      _entityType;
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum?
      get entityType => _$this._entityType;
  set entityType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum?
              entityType) =>
      _$this._entityType = entityType;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder? _payload;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder get payload =>
      _$this._payload ??=
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder();
  set payload(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder? payload) =>
      _$this._payload = payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder() {
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
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
      GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf',
                'id'),
            entityType: BuiltValueNullFieldError.checkNotNull(
                entityType,
                r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf',
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
            r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf',
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
