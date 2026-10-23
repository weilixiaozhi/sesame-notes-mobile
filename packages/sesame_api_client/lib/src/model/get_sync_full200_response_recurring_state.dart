//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_sync_full200_response_recurring_state_occurrences_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response_recurring_state_rules_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_full200_response_recurring_state.g.dart';

/// GetSyncFull200ResponseRecurringState
///
/// Properties:
/// * [rules]
/// * [occurrences]
@BuiltValue()
abstract class GetSyncFull200ResponseRecurringState
    implements
        Built<GetSyncFull200ResponseRecurringState,
            GetSyncFull200ResponseRecurringStateBuilder> {
  @BuiltValueField(wireName: r'rules')
  BuiltList<GetSyncFull200ResponseRecurringStateRulesInner> get rules;

  @BuiltValueField(wireName: r'occurrences')
  BuiltList<GetSyncFull200ResponseRecurringStateOccurrencesInner>
      get occurrences;

  GetSyncFull200ResponseRecurringState._();

  factory GetSyncFull200ResponseRecurringState(
          [void updates(GetSyncFull200ResponseRecurringStateBuilder b)]) =
      _$GetSyncFull200ResponseRecurringState;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncFull200ResponseRecurringStateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFull200ResponseRecurringState> get serializer =>
      _$GetSyncFull200ResponseRecurringStateSerializer();
}

class _$GetSyncFull200ResponseRecurringStateSerializer
    implements PrimitiveSerializer<GetSyncFull200ResponseRecurringState> {
  @override
  final Iterable<Type> types = const [
    GetSyncFull200ResponseRecurringState,
    _$GetSyncFull200ResponseRecurringState
  ];

  @override
  final String wireName = r'GetSyncFull200ResponseRecurringState';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFull200ResponseRecurringState object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rules';
    yield serializers.serialize(
      object.rules,
      specifiedType: const FullType(BuiltList,
          [FullType(GetSyncFull200ResponseRecurringStateRulesInner)]),
    );
    yield r'occurrences';
    yield serializers.serialize(
      object.occurrences,
      specifiedType: const FullType(BuiltList,
          [FullType(GetSyncFull200ResponseRecurringStateOccurrencesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFull200ResponseRecurringState object, {
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
    required GetSyncFull200ResponseRecurringStateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'rules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetSyncFull200ResponseRecurringStateRulesInner)]),
          ) as BuiltList<GetSyncFull200ResponseRecurringStateRulesInner>;
          result.rules.replace(valueDes);
          break;
        case r'occurrences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetSyncFull200ResponseRecurringStateOccurrencesInner)
            ]),
          ) as BuiltList<GetSyncFull200ResponseRecurringStateOccurrencesInner>;
          result.occurrences.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFull200ResponseRecurringState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFull200ResponseRecurringStateBuilder();
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
