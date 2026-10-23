//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_ledgers_by_ledger_id_request.g.dart';

/// PatchLedgersByLedgerIdRequest
///
/// Properties:
/// * [name]
/// * [currency]
/// * [monthStartDay]
/// * [aaEnabled]
@BuiltValue()
abstract class PatchLedgersByLedgerIdRequest
    implements
        Built<PatchLedgersByLedgerIdRequest,
            PatchLedgersByLedgerIdRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'month_start_day')
  int? get monthStartDay;

  @BuiltValueField(wireName: r'aa_enabled')
  bool? get aaEnabled;

  PatchLedgersByLedgerIdRequest._();

  factory PatchLedgersByLedgerIdRequest(
          [void updates(PatchLedgersByLedgerIdRequestBuilder b)]) =
      _$PatchLedgersByLedgerIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchLedgersByLedgerIdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchLedgersByLedgerIdRequest> get serializer =>
      _$PatchLedgersByLedgerIdRequestSerializer();
}

class _$PatchLedgersByLedgerIdRequestSerializer
    implements PrimitiveSerializer<PatchLedgersByLedgerIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchLedgersByLedgerIdRequest,
    _$PatchLedgersByLedgerIdRequest
  ];

  @override
  final String wireName = r'PatchLedgersByLedgerIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchLedgersByLedgerIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
    if (object.monthStartDay != null) {
      yield r'month_start_day';
      yield serializers.serialize(
        object.monthStartDay,
        specifiedType: const FullType(int),
      );
    }
    if (object.aaEnabled != null) {
      yield r'aa_enabled';
      yield serializers.serialize(
        object.aaEnabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchLedgersByLedgerIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PatchLedgersByLedgerIdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currency = valueDes;
          break;
        case r'month_start_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.monthStartDay = valueDes;
          break;
        case r'aa_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.aaEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchLedgersByLedgerIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchLedgersByLedgerIdRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
