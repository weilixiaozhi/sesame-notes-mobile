//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/ledger.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_change_currency200_response.g.dart';

/// PostLedgersByLedgerIdChangeCurrency200Response
///
/// Properties:
/// * [ledger]
/// * [updatedTransactions]
@BuiltValue()
abstract class PostLedgersByLedgerIdChangeCurrency200Response
    implements
        Built<PostLedgersByLedgerIdChangeCurrency200Response,
            PostLedgersByLedgerIdChangeCurrency200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger')
  Ledger get ledger;

  @BuiltValueField(wireName: r'updated_transactions')
  int get updatedTransactions;

  PostLedgersByLedgerIdChangeCurrency200Response._();

  factory PostLedgersByLedgerIdChangeCurrency200Response(
          [void updates(
              PostLedgersByLedgerIdChangeCurrency200ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdChangeCurrency200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdChangeCurrency200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdChangeCurrency200Response>
      get serializer =>
          _$PostLedgersByLedgerIdChangeCurrency200ResponseSerializer();
}

class _$PostLedgersByLedgerIdChangeCurrency200ResponseSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdChangeCurrency200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdChangeCurrency200Response,
    _$PostLedgersByLedgerIdChangeCurrency200Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdChangeCurrency200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdChangeCurrency200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger';
    yield serializers.serialize(
      object.ledger,
      specifiedType: const FullType(Ledger),
    );
    yield r'updated_transactions';
    yield serializers.serialize(
      object.updatedTransactions,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdChangeCurrency200Response object, {
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
    required PostLedgersByLedgerIdChangeCurrency200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Ledger),
          ) as Ledger;
          result.ledger.replace(valueDes);
          break;
        case r'updated_transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedTransactions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdChangeCurrency200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdChangeCurrency200ResponseBuilder();
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
