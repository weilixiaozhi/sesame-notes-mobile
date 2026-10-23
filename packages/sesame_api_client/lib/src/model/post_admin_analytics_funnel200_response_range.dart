//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_analytics_funnel200_response_range.g.dart';

/// PostAdminAnalyticsFunnel200ResponseRange
///
/// Properties:
/// * [startDate]
/// * [endDate]
/// * [timezone]
/// * [platform]
@BuiltValue()
abstract class PostAdminAnalyticsFunnel200ResponseRange
    implements
        Built<PostAdminAnalyticsFunnel200ResponseRange,
            PostAdminAnalyticsFunnel200ResponseRangeBuilder> {
  @BuiltValueField(wireName: r'start_date')
  String get startDate;

  @BuiltValueField(wireName: r'end_date')
  String get endDate;

  @BuiltValueField(wireName: r'timezone')
  PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum get timezone;
  // enum timezoneEnum {  Asia/Shanghai,  };

  @BuiltValueField(wireName: r'platform')
  PostAdminAnalyticsFunnel200ResponseRangePlatformEnum get platform;
  // enum platformEnum {  all,  app,  web,  };

  PostAdminAnalyticsFunnel200ResponseRange._();

  factory PostAdminAnalyticsFunnel200ResponseRange(
          [void updates(PostAdminAnalyticsFunnel200ResponseRangeBuilder b)]) =
      _$PostAdminAnalyticsFunnel200ResponseRange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAnalyticsFunnel200ResponseRangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAnalyticsFunnel200ResponseRange> get serializer =>
      _$PostAdminAnalyticsFunnel200ResponseRangeSerializer();
}

class _$PostAdminAnalyticsFunnel200ResponseRangeSerializer
    implements PrimitiveSerializer<PostAdminAnalyticsFunnel200ResponseRange> {
  @override
  final Iterable<Type> types = const [
    PostAdminAnalyticsFunnel200ResponseRange,
    _$PostAdminAnalyticsFunnel200ResponseRange
  ];

  @override
  final String wireName = r'PostAdminAnalyticsFunnel200ResponseRange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseRange object, {
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
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType:
          const FullType(PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType:
          const FullType(PostAdminAnalyticsFunnel200ResponseRangePlatformEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseRange object, {
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
    required PostAdminAnalyticsFunnel200ResponseRangeBuilder result,
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
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum),
          ) as PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum;
          result.timezone = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostAdminAnalyticsFunnel200ResponseRangePlatformEnum),
          ) as PostAdminAnalyticsFunnel200ResponseRangePlatformEnum;
          result.platform = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAnalyticsFunnel200ResponseRange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAnalyticsFunnel200ResponseRangeBuilder();
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

class PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Asia/Shanghai')
  static const PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum
      asiaSlashShanghai =
      _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnum_asiaSlashShanghai;

  static Serializer<PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>
      get serializer =>
          _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumSerializer;

  const PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum>
      get values =>
          _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumValues;
  static PostAdminAnalyticsFunnel200ResponseRangeTimezoneEnum valueOf(
          String name) =>
      _$postAdminAnalyticsFunnel200ResponseRangeTimezoneEnumValueOf(name);
}

class PostAdminAnalyticsFunnel200ResponseRangePlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'all')
  static const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum all =
      _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_all;
  @BuiltValueEnumConst(wireName: r'app')
  static const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum app =
      _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum web =
      _$postAdminAnalyticsFunnel200ResponseRangePlatformEnum_web;

  static Serializer<PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>
      get serializer =>
          _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumSerializer;

  const PostAdminAnalyticsFunnel200ResponseRangePlatformEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminAnalyticsFunnel200ResponseRangePlatformEnum>
      get values =>
          _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumValues;
  static PostAdminAnalyticsFunnel200ResponseRangePlatformEnum valueOf(
          String name) =>
      _$postAdminAnalyticsFunnel200ResponseRangePlatformEnumValueOf(name);
}
