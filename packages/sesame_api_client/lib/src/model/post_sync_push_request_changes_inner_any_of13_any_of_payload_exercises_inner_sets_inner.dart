//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of13_any_of_payload_exercises_inner_sets_inner.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
///
/// Properties:
/// * [id]
/// * [kind]
/// * [weight]
/// * [weightLeft]
/// * [weightRight]
/// * [reps]
/// * [completed]
/// * [restDurationsSeconds]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
    implements
        Built<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      get kind;
  // enum kindEnum {  warmup,  working,  };

  @BuiltValueField(wireName: r'weight')
  String? get weight;

  @BuiltValueField(wireName: r'weight_left')
  String? get weightLeft;

  @BuiltValueField(wireName: r'weight_right')
  String? get weightRight;

  @BuiltValueField(wireName: r'reps')
  int? get reps;

  @BuiltValueField(wireName: r'completed')
  bool get completed;

  @BuiltValueField(wireName: r'rest_durations_seconds')
  BuiltList<int>? get restDurationsSeconds;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner._();

  factory PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner,
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum),
    );
    yield r'weight';
    yield object.weight == null
        ? null
        : serializers.serialize(
            object.weight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_left';
    yield object.weightLeft == null
        ? null
        : serializers.serialize(
            object.weightLeft,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_right';
    yield object.weightRight == null
        ? null
        : serializers.serialize(
            object.weightRight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reps';
    yield object.reps == null
        ? null
        : serializers.serialize(
            object.reps,
            specifiedType: const FullType.nullable(int),
          );
    yield r'completed';
    yield serializers.serialize(
      object.completed,
      specifiedType: const FullType(bool),
    );
    if (object.restDurationsSeconds != null) {
      yield r'rest_durations_seconds';
      yield serializers.serialize(
        object.restDurationsSeconds,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
        object, {
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
    required PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder
        result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weight = valueDes;
          break;
        case r'weight_left':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightLeft = valueDes;
          break;
        case r'weight_right':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightRight = valueDes;
          break;
        case r'reps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.reps = valueDes;
          break;
        case r'completed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.completed = valueDes;
          break;
        case r'rest_durations_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(int)]),
          ) as BuiltList<int>?;
          if (valueDes == null) continue;
          result.restDurationsSeconds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'warmup')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      warmup =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_warmup;
  @BuiltValueEnumConst(wireName: r'working')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      working =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum_working;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnum
      valueOf(String name) =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInnerKindEnumValueOf(
              name);
}
