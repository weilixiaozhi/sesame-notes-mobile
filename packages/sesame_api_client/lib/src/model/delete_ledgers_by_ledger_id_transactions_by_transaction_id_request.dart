//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_ledgers_by_ledger_id_transactions_by_transaction_id_request.g.dart';

/// DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest
///
/// Properties:
/// * [baseRevision]
@BuiltValue()
abstract class DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest
    implements
        Built<DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest,
            DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder> {
  @BuiltValueField(wireName: r'base_revision')
  int get baseRevision;

  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest._();

  factory DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest(
          [void updates(
              DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
                  b)]) =
      _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest>
      get serializer =>
          _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestSerializer();
}

class _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestSerializer
    implements
        PrimitiveSerializer<
            DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest> {
  @override
  final Iterable<Type> types = const [
    DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest,
    _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest
  ];

  @override
  final String wireName =
      r'DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'base_revision';
    yield serializers.serialize(
      object.baseRevision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest object, {
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
    required DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'base_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.baseRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder();
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
