//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics200_response_range.g.dart';

/// GetAdminAnalytics200ResponseRange
///
/// Properties:
/// * [startDate]
/// * [endDate]
/// * [timezone]
/// * [platform]
/// * [bucket]
@BuiltValue()
abstract class GetAdminAnalytics200ResponseRange
    implements
        Built<GetAdminAnalytics200ResponseRange,
            GetAdminAnalytics200ResponseRangeBuilder> {
  @BuiltValueField(wireName: r'start_date')
  String get startDate;

  @BuiltValueField(wireName: r'end_date')
  String get endDate;

  @BuiltValueField(wireName: r'timezone')
  GetAdminAnalytics200ResponseRangeTimezoneEnum get timezone;
  // enum timezoneEnum {  Asia/Shanghai,  };

  @BuiltValueField(wireName: r'platform')
  GetAdminAnalytics200ResponseRangePlatformEnum get platform;
  // enum platformEnum {  all,  app,  web,  };

  @BuiltValueField(wireName: r'bucket')
  GetAdminAnalytics200ResponseRangeBucketEnum get bucket;
  // enum bucketEnum {  hour,  day,  month,  };

  GetAdminAnalytics200ResponseRange._();

  factory GetAdminAnalytics200ResponseRange(
          [void updates(GetAdminAnalytics200ResponseRangeBuilder b)]) =
      _$GetAdminAnalytics200ResponseRange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalytics200ResponseRangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalytics200ResponseRange> get serializer =>
      _$GetAdminAnalytics200ResponseRangeSerializer();
}

class _$GetAdminAnalytics200ResponseRangeSerializer
    implements PrimitiveSerializer<GetAdminAnalytics200ResponseRange> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalytics200ResponseRange,
    _$GetAdminAnalytics200ResponseRange
  ];

  @override
  final String wireName = r'GetAdminAnalytics200ResponseRange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalytics200ResponseRange object, {
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
          const FullType(GetAdminAnalytics200ResponseRangeTimezoneEnum),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType:
          const FullType(GetAdminAnalytics200ResponseRangePlatformEnum),
    );
    yield r'bucket';
    yield serializers.serialize(
      object.bucket,
      specifiedType:
          const FullType(GetAdminAnalytics200ResponseRangeBucketEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalytics200ResponseRange object, {
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
    required GetAdminAnalytics200ResponseRangeBuilder result,
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
            specifiedType:
                const FullType(GetAdminAnalytics200ResponseRangeTimezoneEnum),
          ) as GetAdminAnalytics200ResponseRangeTimezoneEnum;
          result.timezone = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminAnalytics200ResponseRangePlatformEnum),
          ) as GetAdminAnalytics200ResponseRangePlatformEnum;
          result.platform = valueDes;
          break;
        case r'bucket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminAnalytics200ResponseRangeBucketEnum),
          ) as GetAdminAnalytics200ResponseRangeBucketEnum;
          result.bucket = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalytics200ResponseRange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalytics200ResponseRangeBuilder();
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

class GetAdminAnalytics200ResponseRangeTimezoneEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Asia/Shanghai')
  static const GetAdminAnalytics200ResponseRangeTimezoneEnum asiaSlashShanghai =
      _$getAdminAnalytics200ResponseRangeTimezoneEnum_asiaSlashShanghai;

  static Serializer<GetAdminAnalytics200ResponseRangeTimezoneEnum>
      get serializer =>
          _$getAdminAnalytics200ResponseRangeTimezoneEnumSerializer;

  const GetAdminAnalytics200ResponseRangeTimezoneEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminAnalytics200ResponseRangeTimezoneEnum> get values =>
      _$getAdminAnalytics200ResponseRangeTimezoneEnumValues;
  static GetAdminAnalytics200ResponseRangeTimezoneEnum valueOf(String name) =>
      _$getAdminAnalytics200ResponseRangeTimezoneEnumValueOf(name);
}

class GetAdminAnalytics200ResponseRangePlatformEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'all')
  static const GetAdminAnalytics200ResponseRangePlatformEnum all =
      _$getAdminAnalytics200ResponseRangePlatformEnum_all;
  @BuiltValueEnumConst(wireName: r'app')
  static const GetAdminAnalytics200ResponseRangePlatformEnum app =
      _$getAdminAnalytics200ResponseRangePlatformEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const GetAdminAnalytics200ResponseRangePlatformEnum web =
      _$getAdminAnalytics200ResponseRangePlatformEnum_web;

  static Serializer<GetAdminAnalytics200ResponseRangePlatformEnum>
      get serializer =>
          _$getAdminAnalytics200ResponseRangePlatformEnumSerializer;

  const GetAdminAnalytics200ResponseRangePlatformEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminAnalytics200ResponseRangePlatformEnum> get values =>
      _$getAdminAnalytics200ResponseRangePlatformEnumValues;
  static GetAdminAnalytics200ResponseRangePlatformEnum valueOf(String name) =>
      _$getAdminAnalytics200ResponseRangePlatformEnumValueOf(name);
}

class GetAdminAnalytics200ResponseRangeBucketEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'hour')
  static const GetAdminAnalytics200ResponseRangeBucketEnum hour =
      _$getAdminAnalytics200ResponseRangeBucketEnum_hour;
  @BuiltValueEnumConst(wireName: r'day')
  static const GetAdminAnalytics200ResponseRangeBucketEnum day =
      _$getAdminAnalytics200ResponseRangeBucketEnum_day;
  @BuiltValueEnumConst(wireName: r'month')
  static const GetAdminAnalytics200ResponseRangeBucketEnum month =
      _$getAdminAnalytics200ResponseRangeBucketEnum_month;

  static Serializer<GetAdminAnalytics200ResponseRangeBucketEnum>
      get serializer => _$getAdminAnalytics200ResponseRangeBucketEnumSerializer;

  const GetAdminAnalytics200ResponseRangeBucketEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminAnalytics200ResponseRangeBucketEnum> get values =>
      _$getAdminAnalytics200ResponseRangeBucketEnumValues;
  static GetAdminAnalytics200ResponseRangeBucketEnum valueOf(String name) =>
      _$getAdminAnalytics200ResponseRangeBucketEnumValueOf(name);
}
