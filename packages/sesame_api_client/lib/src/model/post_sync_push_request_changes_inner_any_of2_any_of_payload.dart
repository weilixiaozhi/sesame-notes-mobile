//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of2_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
///
/// Properties:
/// * [name]
/// * [currency]
/// * [monthStartDay]
/// * [aaEnabled]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'month_start_day')
  int get monthStartDay;

  @BuiltValueField(wireName: r'aa_enabled')
  bool get aaEnabled;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'month_start_day';
    yield serializers.serialize(
      object.monthStartDay,
      specifiedType: const FullType(int),
    );
    yield r'aa_enabled';
    yield serializers.serialize(
      object.aaEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'month_start_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.monthStartDay = valueDes;
          break;
        case r'aa_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
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
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder();
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
