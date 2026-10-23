//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_details200_response_summary.g.dart';

/// GetAdminAnalyticsDetails200ResponseSummary
///
/// Properties:
/// * [pageViews]
/// * [visitors]
/// * [clicks]
/// * [clickUsers]
/// * [completions]
/// * [completionUsers]
@BuiltValue()
abstract class GetAdminAnalyticsDetails200ResponseSummary
    implements
        Built<GetAdminAnalyticsDetails200ResponseSummary,
            GetAdminAnalyticsDetails200ResponseSummaryBuilder> {
  @BuiltValueField(wireName: r'page_views')
  int get pageViews;

  @BuiltValueField(wireName: r'visitors')
  int get visitors;

  @BuiltValueField(wireName: r'clicks')
  int get clicks;

  @BuiltValueField(wireName: r'click_users')
  int get clickUsers;

  @BuiltValueField(wireName: r'completions')
  int get completions;

  @BuiltValueField(wireName: r'completion_users')
  int get completionUsers;

  GetAdminAnalyticsDetails200ResponseSummary._();

  factory GetAdminAnalyticsDetails200ResponseSummary(
          [void updates(GetAdminAnalyticsDetails200ResponseSummaryBuilder b)]) =
      _$GetAdminAnalyticsDetails200ResponseSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalyticsDetails200ResponseSummaryBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsDetails200ResponseSummary>
      get serializer =>
          _$GetAdminAnalyticsDetails200ResponseSummarySerializer();
}

class _$GetAdminAnalyticsDetails200ResponseSummarySerializer
    implements PrimitiveSerializer<GetAdminAnalyticsDetails200ResponseSummary> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsDetails200ResponseSummary,
    _$GetAdminAnalyticsDetails200ResponseSummary
  ];

  @override
  final String wireName = r'GetAdminAnalyticsDetails200ResponseSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponseSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'page_views';
    yield serializers.serialize(
      object.pageViews,
      specifiedType: const FullType(int),
    );
    yield r'visitors';
    yield serializers.serialize(
      object.visitors,
      specifiedType: const FullType(int),
    );
    yield r'clicks';
    yield serializers.serialize(
      object.clicks,
      specifiedType: const FullType(int),
    );
    yield r'click_users';
    yield serializers.serialize(
      object.clickUsers,
      specifiedType: const FullType(int),
    );
    yield r'completions';
    yield serializers.serialize(
      object.completions,
      specifiedType: const FullType(int),
    );
    yield r'completion_users';
    yield serializers.serialize(
      object.completionUsers,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponseSummary object, {
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
    required GetAdminAnalyticsDetails200ResponseSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'page_views':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageViews = valueDes;
          break;
        case r'visitors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.visitors = valueDes;
          break;
        case r'clicks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.clicks = valueDes;
          break;
        case r'click_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.clickUsers = valueDes;
          break;
        case r'completions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completions = valueDes;
          break;
        case r'completion_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completionUsers = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalyticsDetails200ResponseSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsDetails200ResponseSummaryBuilder();
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
