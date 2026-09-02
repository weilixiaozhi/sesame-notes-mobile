//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of4_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
///
/// Properties:
/// * [baseCurrency]
/// * [quoteCurrency]
/// * [rate]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'base_currency')
  String get baseCurrency;

  @BuiltValueField(wireName: r'quote_currency')
  String get quoteCurrency;

  @BuiltValueField(wireName: r'rate')
  String get rate;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'base_currency';
    yield serializers.serialize(
      object.baseCurrency,
      specifiedType: const FullType(String),
    );
    yield r'quote_currency';
    yield serializers.serialize(
      object.quoteCurrency,
      specifiedType: const FullType(String),
    );
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'base_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.baseCurrency = valueDes;
          break;
        case r'quote_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quoteCurrency = valueDes;
          break;
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder();
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
