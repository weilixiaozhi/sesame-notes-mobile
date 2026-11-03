//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_transaction_edit_history200_response_items_inner.g.dart';

/// GetTransactionEditHistory200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [transactionId]
/// * [ledgerId]
/// * [version]
/// * [operatorMemberId]
/// * [operatorDisplayName]
/// * [createdAt]
/// * [changes]
@BuiltValue()
abstract class GetTransactionEditHistory200ResponseItemsInner
    implements
        Built<GetTransactionEditHistory200ResponseItemsInner,
            GetTransactionEditHistory200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'transaction_id')
  String get transactionId;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'operator_member_id')
  String? get operatorMemberId;

  @BuiltValueField(wireName: r'operator_display_name')
  String? get operatorDisplayName;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'changes')
  JsonObject? get changes;

  GetTransactionEditHistory200ResponseItemsInner._();

  factory GetTransactionEditHistory200ResponseItemsInner(
          [void updates(
              GetTransactionEditHistory200ResponseItemsInnerBuilder b)]) =
      _$GetTransactionEditHistory200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetTransactionEditHistory200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetTransactionEditHistory200ResponseItemsInner>
      get serializer =>
          _$GetTransactionEditHistory200ResponseItemsInnerSerializer();
}

class _$GetTransactionEditHistory200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<GetTransactionEditHistory200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetTransactionEditHistory200ResponseItemsInner,
    _$GetTransactionEditHistory200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetTransactionEditHistory200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetTransactionEditHistory200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'transaction_id';
    yield serializers.serialize(
      object.transactionId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'operator_member_id';
    yield object.operatorMemberId == null
        ? null
        : serializers.serialize(
            object.operatorMemberId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'operator_display_name';
    yield object.operatorDisplayName == null
        ? null
        : serializers.serialize(
            object.operatorDisplayName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'changes';
    yield object.changes == null
        ? null
        : serializers.serialize(
            object.changes,
            specifiedType: const FullType.nullable(JsonObject),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetTransactionEditHistory200ResponseItemsInner object, {
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
    required GetTransactionEditHistory200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'transaction_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.transactionId = valueDes;
          break;
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'operator_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.operatorMemberId = valueDes;
          break;
        case r'operator_display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.operatorDisplayName = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.changes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetTransactionEditHistory200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetTransactionEditHistory200ResponseItemsInnerBuilder();
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
