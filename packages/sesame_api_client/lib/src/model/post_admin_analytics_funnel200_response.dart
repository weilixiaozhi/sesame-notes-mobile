//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_analytics_funnel200_response_steps_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_admin_analytics_funnel200_response_coverage.dart';
import 'package:sesame_api_client/src/model/post_admin_analytics_funnel200_response_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_analytics_funnel200_response.g.dart';

/// PostAdminAnalyticsFunnel200Response
///
/// Properties:
/// * [range]
/// * [scope]
/// * [windowMinutes]
/// * [steps]
/// * [completionRate]
/// * [coverage]
@BuiltValue()
abstract class PostAdminAnalyticsFunnel200Response
    implements
        Built<PostAdminAnalyticsFunnel200Response,
            PostAdminAnalyticsFunnel200ResponseBuilder> {
  @BuiltValueField(wireName: r'range')
  PostAdminAnalyticsFunnel200ResponseRange get range;

  @BuiltValueField(wireName: r'scope')
  PostAdminAnalyticsFunnel200ResponseScopeEnum get scope;
  // enum scopeEnum {  user,  session,  flow,  };

  @BuiltValueField(wireName: r'window_minutes')
  int get windowMinutes;

  @BuiltValueField(wireName: r'steps')
  BuiltList<PostAdminAnalyticsFunnel200ResponseStepsInner> get steps;

  @BuiltValueField(wireName: r'completion_rate')
  num? get completionRate;

  @BuiltValueField(wireName: r'coverage')
  PostAdminAnalyticsFunnel200ResponseCoverage get coverage;

  PostAdminAnalyticsFunnel200Response._();

  factory PostAdminAnalyticsFunnel200Response(
          [void updates(PostAdminAnalyticsFunnel200ResponseBuilder b)]) =
      _$PostAdminAnalyticsFunnel200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAnalyticsFunnel200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAnalyticsFunnel200Response> get serializer =>
      _$PostAdminAnalyticsFunnel200ResponseSerializer();
}

class _$PostAdminAnalyticsFunnel200ResponseSerializer
    implements PrimitiveSerializer<PostAdminAnalyticsFunnel200Response> {
  @override
  final Iterable<Type> types = const [
    PostAdminAnalyticsFunnel200Response,
    _$PostAdminAnalyticsFunnel200Response
  ];

  @override
  final String wireName = r'PostAdminAnalyticsFunnel200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAnalyticsFunnel200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(PostAdminAnalyticsFunnel200ResponseRange),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType:
          const FullType(PostAdminAnalyticsFunnel200ResponseScopeEnum),
    );
    yield r'window_minutes';
    yield serializers.serialize(
      object.windowMinutes,
      specifiedType: const FullType(int),
    );
    yield r'steps';
    yield serializers.serialize(
      object.steps,
      specifiedType: const FullType(
          BuiltList, [FullType(PostAdminAnalyticsFunnel200ResponseStepsInner)]),
    );
    yield r'completion_rate';
    yield object.completionRate == null
        ? null
        : serializers.serialize(
            object.completionRate,
            specifiedType: const FullType.nullable(num),
          );
    yield r'coverage';
    yield serializers.serialize(
      object.coverage,
      specifiedType:
          const FullType(PostAdminAnalyticsFunnel200ResponseCoverage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAnalyticsFunnel200Response object, {
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
    required PostAdminAnalyticsFunnel200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminAnalyticsFunnel200ResponseRange),
          ) as PostAdminAnalyticsFunnel200ResponseRange;
          result.range.replace(valueDes);
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminAnalyticsFunnel200ResponseScopeEnum),
          ) as PostAdminAnalyticsFunnel200ResponseScopeEnum;
          result.scope = valueDes;
          break;
        case r'window_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.windowMinutes = valueDes;
          break;
        case r'steps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(PostAdminAnalyticsFunnel200ResponseStepsInner)]),
          ) as BuiltList<PostAdminAnalyticsFunnel200ResponseStepsInner>;
          result.steps.replace(valueDes);
          break;
        case r'completion_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.completionRate = valueDes;
          break;
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminAnalyticsFunnel200ResponseCoverage),
          ) as PostAdminAnalyticsFunnel200ResponseCoverage;
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
  PostAdminAnalyticsFunnel200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAnalyticsFunnel200ResponseBuilder();
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

class PostAdminAnalyticsFunnel200ResponseScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'user')
  static const PostAdminAnalyticsFunnel200ResponseScopeEnum user =
      _$postAdminAnalyticsFunnel200ResponseScopeEnum_user;
  @BuiltValueEnumConst(wireName: r'session')
  static const PostAdminAnalyticsFunnel200ResponseScopeEnum session =
      _$postAdminAnalyticsFunnel200ResponseScopeEnum_session;
  @BuiltValueEnumConst(wireName: r'flow')
  static const PostAdminAnalyticsFunnel200ResponseScopeEnum flow =
      _$postAdminAnalyticsFunnel200ResponseScopeEnum_flow;

  static Serializer<PostAdminAnalyticsFunnel200ResponseScopeEnum>
      get serializer =>
          _$postAdminAnalyticsFunnel200ResponseScopeEnumSerializer;

  const PostAdminAnalyticsFunnel200ResponseScopeEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminAnalyticsFunnel200ResponseScopeEnum> get values =>
      _$postAdminAnalyticsFunnel200ResponseScopeEnumValues;
  static PostAdminAnalyticsFunnel200ResponseScopeEnum valueOf(String name) =>
      _$postAdminAnalyticsFunnel200ResponseScopeEnumValueOf(name);
}
