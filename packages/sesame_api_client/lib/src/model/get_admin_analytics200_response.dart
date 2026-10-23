//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_coverage.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_range.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_series_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_summary.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics200_response.g.dart';

/// GetAdminAnalytics200Response
///
/// Properties:
/// * [range]
/// * [summary]
/// * [series]
/// * [coverage]
@BuiltValue()
abstract class GetAdminAnalytics200Response
    implements
        Built<GetAdminAnalytics200Response,
            GetAdminAnalytics200ResponseBuilder> {
  @BuiltValueField(wireName: r'range')
  GetAdminAnalytics200ResponseRange get range;

  @BuiltValueField(wireName: r'summary')
  GetAdminAnalytics200ResponseSummary get summary;

  @BuiltValueField(wireName: r'series')
  BuiltList<GetAdminAnalytics200ResponseSeriesInner> get series;

  @BuiltValueField(wireName: r'coverage')
  GetAdminAnalytics200ResponseCoverage get coverage;

  GetAdminAnalytics200Response._();

  factory GetAdminAnalytics200Response(
          [void updates(GetAdminAnalytics200ResponseBuilder b)]) =
      _$GetAdminAnalytics200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalytics200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalytics200Response> get serializer =>
      _$GetAdminAnalytics200ResponseSerializer();
}

class _$GetAdminAnalytics200ResponseSerializer
    implements PrimitiveSerializer<GetAdminAnalytics200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalytics200Response,
    _$GetAdminAnalytics200Response
  ];

  @override
  final String wireName = r'GetAdminAnalytics200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalytics200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(GetAdminAnalytics200ResponseRange),
    );
    yield r'summary';
    yield serializers.serialize(
      object.summary,
      specifiedType: const FullType(GetAdminAnalytics200ResponseSummary),
    );
    yield r'series';
    yield serializers.serialize(
      object.series,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminAnalytics200ResponseSeriesInner)]),
    );
    yield r'coverage';
    yield serializers.serialize(
      object.coverage,
      specifiedType: const FullType(GetAdminAnalytics200ResponseCoverage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalytics200Response object, {
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
    required GetAdminAnalytics200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminAnalytics200ResponseRange),
          ) as GetAdminAnalytics200ResponseRange;
          result.range.replace(valueDes);
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminAnalytics200ResponseSummary),
          ) as GetAdminAnalytics200ResponseSummary;
          result.summary.replace(valueDes);
          break;
        case r'series':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(GetAdminAnalytics200ResponseSeriesInner)]),
          ) as BuiltList<GetAdminAnalytics200ResponseSeriesInner>;
          result.series.replace(valueDes);
          break;
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetAdminAnalytics200ResponseCoverage),
          ) as GetAdminAnalytics200ResponseCoverage;
          result.coverage.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalytics200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalytics200ResponseBuilder();
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
