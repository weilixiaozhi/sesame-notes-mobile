//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_sync_fitness_spaces_full200_response_fitness_space.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_fitness_spaces_full200_response.g.dart';

/// GetSyncFitnessSpacesFull200Response
///
/// Properties:
/// * [fitnessSpace]
/// * [fitnessTemplates]
/// * [fitnessPlans]
/// * [fitnessWorkouts]
/// * [fitnessPreferences]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncFitnessSpacesFull200Response
    implements
        Built<GetSyncFitnessSpacesFull200Response,
            GetSyncFitnessSpacesFull200ResponseBuilder> {
  @BuiltValueField(wireName: r'fitness_space')
  GetSyncFitnessSpacesFull200ResponseFitnessSpace get fitnessSpace;

  @BuiltValueField(wireName: r'fitness_templates')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>
      get fitnessTemplates;

  @BuiltValueField(wireName: r'fitness_plans')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>
      get fitnessPlans;

  @BuiltValueField(wireName: r'fitness_workouts')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      get fitnessWorkouts;

  @BuiltValueField(wireName: r'fitness_preferences')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      get fitnessPreferences;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncFitnessSpacesFull200Response._();

  factory GetSyncFitnessSpacesFull200Response(
          [void updates(GetSyncFitnessSpacesFull200ResponseBuilder b)]) =
      _$GetSyncFitnessSpacesFull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncFitnessSpacesFull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFitnessSpacesFull200Response> get serializer =>
      _$GetSyncFitnessSpacesFull200ResponseSerializer();
}

class _$GetSyncFitnessSpacesFull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncFitnessSpacesFull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncFitnessSpacesFull200Response,
    _$GetSyncFitnessSpacesFull200Response
  ];

  @override
  final String wireName = r'GetSyncFitnessSpacesFull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFitnessSpacesFull200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fitness_space';
    yield serializers.serialize(
      object.fitnessSpace,
      specifiedType:
          const FullType(GetSyncFitnessSpacesFull200ResponseFitnessSpace),
    );
    yield r'fitness_templates';
    yield serializers.serialize(
      object.fitnessTemplates,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner)
      ]),
    );
    yield r'fitness_plans';
    yield serializers.serialize(
      object.fitnessPlans,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner)
      ]),
    );
    yield r'fitness_workouts';
    yield serializers.serialize(
      object.fitnessWorkouts,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
      ]),
    );
    yield r'fitness_preferences';
    yield serializers.serialize(
      object.fitnessPreferences,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
      ]),
    );
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFitnessSpacesFull200Response object, {
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
    required GetSyncFitnessSpacesFull200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fitness_space':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetSyncFitnessSpacesFull200ResponseFitnessSpace),
          ) as GetSyncFitnessSpacesFull200ResponseFitnessSpace;
          result.fitnessSpace.replace(valueDes);
          break;
        case r'fitness_templates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>;
          result.fitnessTemplates.replace(valueDes);
          break;
        case r'fitness_plans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner>;
          result.fitnessPlans.replace(valueDes);
          break;
        case r'fitness_workouts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>;
          result.fitnessWorkouts.replace(valueDes);
          break;
        case r'fitness_preferences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>;
          result.fitnessPreferences.replace(valueDes);
          break;
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFitnessSpacesFull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFitnessSpacesFull200ResponseBuilder();
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
