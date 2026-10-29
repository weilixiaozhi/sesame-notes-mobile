//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_coverage.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics_details200_response_events_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics200_response_range.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics_details200_response_series_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics_details200_response_summary.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics_details200_response_pages_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_analytics_details200_response_exposures_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_details200_response.g.dart';

/// GetAdminAnalyticsDetails200Response
///
/// Properties:
/// * [range]
/// * [summary]
/// * [series]
/// * [pages]
/// * [events]
/// * [exposures]
/// * [coverage]
@BuiltValue()
abstract class GetAdminAnalyticsDetails200Response
    implements
        Built<GetAdminAnalyticsDetails200Response,
            GetAdminAnalyticsDetails200ResponseBuilder> {
  @BuiltValueField(wireName: r'range')
  GetAdminAnalytics200ResponseRange get range;

  @BuiltValueField(wireName: r'summary')
  GetAdminAnalyticsDetails200ResponseSummary get summary;

  @BuiltValueField(wireName: r'series')
  BuiltList<GetAdminAnalyticsDetails200ResponseSeriesInner> get series;

  @BuiltValueField(wireName: r'pages')
  BuiltList<GetAdminAnalyticsDetails200ResponsePagesInner> get pages;

  @BuiltValueField(wireName: r'events')
  BuiltList<GetAdminAnalyticsDetails200ResponseEventsInner> get events;

  @BuiltValueField(wireName: r'exposures')
  BuiltList<GetAdminAnalyticsDetails200ResponseExposuresInner>? get exposures;

  @BuiltValueField(wireName: r'coverage')
  GetAdminAnalytics200ResponseCoverage get coverage;

  GetAdminAnalyticsDetails200Response._();

  factory GetAdminAnalyticsDetails200Response(
          [void updates(GetAdminAnalyticsDetails200ResponseBuilder b)]) =
      _$GetAdminAnalyticsDetails200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalyticsDetails200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsDetails200Response> get serializer =>
      _$GetAdminAnalyticsDetails200ResponseSerializer();
}

class _$GetAdminAnalyticsDetails200ResponseSerializer
    implements PrimitiveSerializer<GetAdminAnalyticsDetails200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsDetails200Response,
    _$GetAdminAnalyticsDetails200Response
  ];

  @override
  final String wireName = r'GetAdminAnalyticsDetails200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsDetails200Response object, {
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
      specifiedType: const FullType(GetAdminAnalyticsDetails200ResponseSummary),
    );
    yield r'series';
    yield serializers.serialize(
      object.series,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminAnalyticsDetails200ResponseSeriesInner)]),
    );
    yield r'pages';
    yield serializers.serialize(
      object.pages,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminAnalyticsDetails200ResponsePagesInner)]),
    );
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminAnalyticsDetails200ResponseEventsInner)]),
    );
    if (object.exposures != null) {
      yield r'exposures';
      yield serializers.serialize(
        object.exposures,
        specifiedType: const FullType(BuiltList,
            [FullType(GetAdminAnalyticsDetails200ResponseExposuresInner)]),
      );
    }
    yield r'coverage';
    yield serializers.serialize(
      object.coverage,
      specifiedType: const FullType(GetAdminAnalytics200ResponseCoverage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsDetails200Response object, {
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
    required GetAdminAnalyticsDetails200ResponseBuilder result,
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
            specifiedType:
                const FullType(GetAdminAnalyticsDetails200ResponseSummary),
          ) as GetAdminAnalyticsDetails200ResponseSummary;
          result.summary.replace(valueDes);
          break;
        case r'series':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminAnalyticsDetails200ResponseSeriesInner)]),
          ) as BuiltList<GetAdminAnalyticsDetails200ResponseSeriesInner>;
          result.series.replace(valueDes);
          break;
        case r'pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminAnalyticsDetails200ResponsePagesInner)]),
          ) as BuiltList<GetAdminAnalyticsDetails200ResponsePagesInner>;
          result.pages.replace(valueDes);
          break;
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminAnalyticsDetails200ResponseEventsInner)]),
          ) as BuiltList<GetAdminAnalyticsDetails200ResponseEventsInner>;
          result.events.replace(valueDes);
          break;
        case r'exposures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList,
                [FullType(GetAdminAnalyticsDetails200ResponseExposuresInner)]),
          ) as BuiltList<GetAdminAnalyticsDetails200ResponseExposuresInner>?;
          if (valueDes == null) continue;
          result.exposures.replace(valueDes);
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
  GetAdminAnalyticsDetails200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsDetails200ResponseBuilder();
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
