//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_clear200_response.g.dart';

/// PostLedgersByLedgerIdClear200Response
///
/// Properties:
/// * [deletedCount]
/// * [syncId]
/// * [replayed]
@BuiltValue()
abstract class PostLedgersByLedgerIdClear200Response
    implements
        Built<PostLedgersByLedgerIdClear200Response,
            PostLedgersByLedgerIdClear200ResponseBuilder> {
  @BuiltValueField(wireName: r'deleted_count')
  int get deletedCount;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'replayed')
  bool get replayed;

  PostLedgersByLedgerIdClear200Response._();

  factory PostLedgersByLedgerIdClear200Response(
          [void updates(PostLedgersByLedgerIdClear200ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdClear200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdClear200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdClear200Response> get serializer =>
      _$PostLedgersByLedgerIdClear200ResponseSerializer();
}

class _$PostLedgersByLedgerIdClear200ResponseSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdClear200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdClear200Response,
    _$PostLedgersByLedgerIdClear200Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdClear200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdClear200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'deleted_count';
    yield serializers.serialize(
      object.deletedCount,
      specifiedType: const FullType(int),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'replayed';
    yield serializers.serialize(
      object.replayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdClear200Response object, {
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
    required PostLedgersByLedgerIdClear200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deleted_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.deletedCount = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.replayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdClear200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdClear200ResponseBuilder();
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
