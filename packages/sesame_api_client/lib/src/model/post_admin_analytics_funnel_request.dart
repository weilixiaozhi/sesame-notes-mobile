//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_analytics_funnel_request.g.dart';

/// PostAdminAnalyticsFunnelRequest
///
/// Properties:
/// * [startDate]
/// * [endDate]
/// * [platform]
/// * [steps]
/// * [scope]
/// * [windowMinutes]
@BuiltValue()
abstract class PostAdminAnalyticsFunnelRequest
    implements
        Built<PostAdminAnalyticsFunnelRequest,
            PostAdminAnalyticsFunnelRequestBuilder> {
  @BuiltValueField(wireName: r'start_date')
  String get startDate;

  @BuiltValueField(wireName: r'end_date')
  String get endDate;

  @BuiltValueField(wireName: r'platform')
  PostAdminAnalyticsFunnelRequestPlatformEnum? get platform;
  // enum platformEnum {  all,  app,  web,  };

  @BuiltValueField(wireName: r'steps')
  BuiltList<String> get steps;

  @BuiltValueField(wireName: r'scope')
  PostAdminAnalyticsFunnelRequestScopeEnum get scope;
  // enum scopeEnum {  user,  session,  flow,  };

  @BuiltValueField(wireName: r'window_minutes')
  int get windowMinutes;

  PostAdminAnalyticsFunnelRequest._();

  factory PostAdminAnalyticsFunnelRequest(
          [void updates(PostAdminAnalyticsFunnelRequestBuilder b)]) =
      _$PostAdminAnalyticsFunnelRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAnalyticsFunnelRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAnalyticsFunnelRequest> get serializer =>
      _$PostAdminAnalyticsFunnelRequestSerializer();
}

class _$PostAdminAnalyticsFunnelRequestSerializer
    implements PrimitiveSerializer<PostAdminAnalyticsFunnelRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminAnalyticsFunnelRequest,
    _$PostAdminAnalyticsFunnelRequest
  ];

  @override
  final String wireName = r'PostAdminAnalyticsFunnelRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAnalyticsFunnelRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'start_date';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(String),
    );
    yield r'end_date';
    yield serializers.serialize(
      object.endDate,
      specifiedType: const FullType(String),
    );
    if (object.platform != null) {
      yield r'platform';
      yield serializers.serialize(
        object.platform,
        specifiedType:
            const FullType(PostAdminAnalyticsFunnelRequestPlatformEnum),
      );
    }
    yield r'steps';
    yield serializers.serialize(
      object.steps,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType: const FullType(PostAdminAnalyticsFunnelRequestScopeEnum),
    );
    yield r'window_minutes';
    yield serializers.serialize(
      object.windowMinutes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAnalyticsFunnelRequest object, {
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
    required PostAdminAnalyticsFunnelRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.startDate = valueDes;
          break;
        case r'end_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.endDate = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostAdminAnalyticsFunnelRequestPlatformEnum),
          ) as PostAdminAnalyticsFunnelRequestPlatformEnum?;
          if (valueDes == null) continue;
          result.platform = valueDes;
          break;
        case r'steps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.steps.replace(valueDes);
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminAnalyticsFunnelRequestScopeEnum),
          ) as PostAdminAnalyticsFunnelRequestScopeEnum;
          result.scope = valueDes;
          break;
        case r'window_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.windowMinutes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAnalyticsFunnelRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAnalyticsFunnelRequestBuilder();
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

class PostAdminAnalyticsFunnelRequestPlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'all')
  static const PostAdminAnalyticsFunnelRequestPlatformEnum all =
      _$postAdminAnalyticsFunnelRequestPlatformEnum_all;
  @BuiltValueEnumConst(wireName: r'app')
  static const PostAdminAnalyticsFunnelRequestPlatformEnum app =
      _$postAdminAnalyticsFunnelRequestPlatformEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const PostAdminAnalyticsFunnelRequestPlatformEnum web =
      _$postAdminAnalyticsFunnelRequestPlatformEnum_web;

  static Serializer<PostAdminAnalyticsFunnelRequestPlatformEnum>
      get serializer => _$postAdminAnalyticsFunnelRequestPlatformEnumSerializer;

  const PostAdminAnalyticsFunnelRequestPlatformEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminAnalyticsFunnelRequestPlatformEnum> get values =>
      _$postAdminAnalyticsFunnelRequestPlatformEnumValues;
  static PostAdminAnalyticsFunnelRequestPlatformEnum valueOf(String name) =>
      _$postAdminAnalyticsFunnelRequestPlatformEnumValueOf(name);
}

class PostAdminAnalyticsFunnelRequestScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'user')
  static const PostAdminAnalyticsFunnelRequestScopeEnum user =
      _$postAdminAnalyticsFunnelRequestScopeEnum_user;
  @BuiltValueEnumConst(wireName: r'session')
  static const PostAdminAnalyticsFunnelRequestScopeEnum session =
      _$postAdminAnalyticsFunnelRequestScopeEnum_session;
  @BuiltValueEnumConst(wireName: r'flow')
  static const PostAdminAnalyticsFunnelRequestScopeEnum flow =
      _$postAdminAnalyticsFunnelRequestScopeEnum_flow;

  static Serializer<PostAdminAnalyticsFunnelRequestScopeEnum> get serializer =>
      _$postAdminAnalyticsFunnelRequestScopeEnumSerializer;

  const PostAdminAnalyticsFunnelRequestScopeEnum._(String name) : super(name);

  static BuiltSet<PostAdminAnalyticsFunnelRequestScopeEnum> get values =>
      _$postAdminAnalyticsFunnelRequestScopeEnumValues;
  static PostAdminAnalyticsFunnelRequestScopeEnum valueOf(String name) =>
      _$postAdminAnalyticsFunnelRequestScopeEnumValueOf(name);
}
