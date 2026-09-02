//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction_split.g.dart';

/// TransactionSplit
///
/// Properties:
/// * [memberId]
/// * [amount]
@BuiltValue()
abstract class TransactionSplit
    implements Built<TransactionSplit, TransactionSplitBuilder> {
  @BuiltValueField(wireName: r'member_id')
  String? get memberId;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  TransactionSplit._();

  factory TransactionSplit([void updates(TransactionSplitBuilder b)]) =
      _$TransactionSplit;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionSplitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransactionSplit> get serializer =>
      _$TransactionSplitSerializer();
}

class _$TransactionSplitSerializer
    implements PrimitiveSerializer<TransactionSplit> {
  @override
  final Iterable<Type> types = const [TransactionSplit, _$TransactionSplit];

  @override
  final String wireName = r'TransactionSplit';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransactionSplit object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'member_id';
    yield object.memberId == null
        ? null
        : serializers.serialize(
            object.memberId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TransactionSplit object, {
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
    required TransactionSplitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.memberId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TransactionSplit deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionSplitBuilder();
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
