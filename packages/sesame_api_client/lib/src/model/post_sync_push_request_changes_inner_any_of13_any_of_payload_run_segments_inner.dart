//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of13_any_of_payload_run_segments_inner.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
///
/// Properties:
/// * [startedAt]
/// * [endedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
    implements
        Built<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder> {
  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner._();

  factory PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner,
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ended_at';
    yield object.endedAt == null
        ? null
        : serializers.serialize(
            object.endedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner object, {
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
    required PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInnerBuilder();
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
