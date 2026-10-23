//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_clear_request.g.dart';

/// PostLedgersByLedgerIdClearRequest
///
/// Properties:
/// * [mutationId]
/// * [expectedSyncId]
/// * [expectedFingerprint]
@BuiltValue()
abstract class PostLedgersByLedgerIdClearRequest
    implements
        Built<PostLedgersByLedgerIdClearRequest,
            PostLedgersByLedgerIdClearRequestBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'expected_sync_id')
  String get expectedSyncId;

  @BuiltValueField(wireName: r'expected_fingerprint')
  String get expectedFingerprint;

  PostLedgersByLedgerIdClearRequest._();

  factory PostLedgersByLedgerIdClearRequest(
          [void updates(PostLedgersByLedgerIdClearRequestBuilder b)]) =
      _$PostLedgersByLedgerIdClearRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdClearRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdClearRequest> get serializer =>
      _$PostLedgersByLedgerIdClearRequestSerializer();
}

class _$PostLedgersByLedgerIdClearRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdClearRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdClearRequest,
    _$PostLedgersByLedgerIdClearRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdClearRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdClearRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'expected_sync_id';
    yield serializers.serialize(
      object.expectedSyncId,
      specifiedType: const FullType(String),
    );
    yield r'expected_fingerprint';
    yield serializers.serialize(
      object.expectedFingerprint,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdClearRequest object, {
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
    required PostLedgersByLedgerIdClearRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutationId = valueDes;
          break;
        case r'expected_sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedSyncId = valueDes;
          break;
        case r'expected_fingerprint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedFingerprint = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdClearRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdClearRequestBuilder();
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
