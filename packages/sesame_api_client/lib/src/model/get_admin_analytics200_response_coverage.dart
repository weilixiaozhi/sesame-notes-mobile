//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics200_response_coverage.g.dart';

/// GetAdminAnalytics200ResponseCoverage
///
/// Properties:
/// * [collectionStartedAt]
/// * [complete]
@BuiltValue()
abstract class GetAdminAnalytics200ResponseCoverage
    implements
        Built<GetAdminAnalytics200ResponseCoverage,
            GetAdminAnalytics200ResponseCoverageBuilder> {
  @BuiltValueField(wireName: r'collection_started_at')
  DateTime get collectionStartedAt;

  @BuiltValueField(wireName: r'complete')
  bool get complete;

  GetAdminAnalytics200ResponseCoverage._();

  factory GetAdminAnalytics200ResponseCoverage(
          [void updates(GetAdminAnalytics200ResponseCoverageBuilder b)]) =
      _$GetAdminAnalytics200ResponseCoverage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalytics200ResponseCoverageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalytics200ResponseCoverage> get serializer =>
      _$GetAdminAnalytics200ResponseCoverageSerializer();
}

class _$GetAdminAnalytics200ResponseCoverageSerializer
    implements PrimitiveSerializer<GetAdminAnalytics200ResponseCoverage> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalytics200ResponseCoverage,
    _$GetAdminAnalytics200ResponseCoverage
  ];

  @override
  final String wireName = r'GetAdminAnalytics200ResponseCoverage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalytics200ResponseCoverage object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalytics200ResponseCoverage object, {
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
    required GetAdminAnalytics200ResponseCoverageBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalytics200ResponseCoverage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalytics200ResponseCoverageBuilder();
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
