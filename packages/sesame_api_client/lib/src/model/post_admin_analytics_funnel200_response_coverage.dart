//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_analytics_funnel200_response_coverage.g.dart';

/// PostAdminAnalyticsFunnel200ResponseCoverage
///
/// Properties:
/// * [collectionStartedAt]
/// * [complete]
/// * [missingContextEvents]
@BuiltValue()
abstract class PostAdminAnalyticsFunnel200ResponseCoverage
    implements
        Built<PostAdminAnalyticsFunnel200ResponseCoverage,
            PostAdminAnalyticsFunnel200ResponseCoverageBuilder> {
  @BuiltValueField(wireName: r'collection_started_at')
  DateTime get collectionStartedAt;

  @BuiltValueField(wireName: r'complete')
  bool get complete;

  @BuiltValueField(wireName: r'missing_context_events')
  int get missingContextEvents;

  PostAdminAnalyticsFunnel200ResponseCoverage._();

  factory PostAdminAnalyticsFunnel200ResponseCoverage(
          [void updates(
              PostAdminAnalyticsFunnel200ResponseCoverageBuilder b)]) =
      _$PostAdminAnalyticsFunnel200ResponseCoverage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAnalyticsFunnel200ResponseCoverageBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAnalyticsFunnel200ResponseCoverage>
      get serializer =>
          _$PostAdminAnalyticsFunnel200ResponseCoverageSerializer();
}

class _$PostAdminAnalyticsFunnel200ResponseCoverageSerializer
    implements
        PrimitiveSerializer<PostAdminAnalyticsFunnel200ResponseCoverage> {
  @override
  final Iterable<Type> types = const [
    PostAdminAnalyticsFunnel200ResponseCoverage,
    _$PostAdminAnalyticsFunnel200ResponseCoverage
  ];

  @override
  final String wireName = r'PostAdminAnalyticsFunnel200ResponseCoverage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseCoverage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'collection_started_at';
    yield serializers.serialize(
      object.collectionStartedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'complete';
    yield serializers.serialize(
      object.complete,
      specifiedType: const FullType(bool),
    );
    yield r'missing_context_events';
    yield serializers.serialize(
      object.missingContextEvents,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseCoverage object, {
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
    required PostAdminAnalyticsFunnel200ResponseCoverageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'collection_started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.collectionStartedAt = valueDes;
          break;
        case r'complete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.complete = valueDes;
          break;
        case r'missing_context_events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.missingContextEvents = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAnalyticsFunnel200ResponseCoverage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAnalyticsFunnel200ResponseCoverageBuilder();
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
