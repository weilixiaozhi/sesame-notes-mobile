//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_banner_statistics200_response_range.g.dart';

/// GetAdminBannerStatistics200ResponseRange
///
/// Properties:
/// * [startDate]
/// * [endDate]
/// * [timezone]
@BuiltValue()
abstract class GetAdminBannerStatistics200ResponseRange
    implements
        Built<GetAdminBannerStatistics200ResponseRange,
            GetAdminBannerStatistics200ResponseRangeBuilder> {
  @BuiltValueField(wireName: r'start_date')
  String get startDate;

  @BuiltValueField(wireName: r'end_date')
  String get endDate;

  @BuiltValueField(wireName: r'timezone')
  GetAdminBannerStatistics200ResponseRangeTimezoneEnum get timezone;
  // enum timezoneEnum {  Asia/Shanghai,  };

  GetAdminBannerStatistics200ResponseRange._();

  factory GetAdminBannerStatistics200ResponseRange(
          [void updates(GetAdminBannerStatistics200ResponseRangeBuilder b)]) =
      _$GetAdminBannerStatistics200ResponseRange;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminBannerStatistics200ResponseRangeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminBannerStatistics200ResponseRange> get serializer =>
      _$GetAdminBannerStatistics200ResponseRangeSerializer();
}

class _$GetAdminBannerStatistics200ResponseRangeSerializer
    implements PrimitiveSerializer<GetAdminBannerStatistics200ResponseRange> {
  @override
  final Iterable<Type> types = const [
    GetAdminBannerStatistics200ResponseRange,
    _$GetAdminBannerStatistics200ResponseRange
  ];

  @override
  final String wireName = r'GetAdminBannerStatistics200ResponseRange';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseRange object, {
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
          const FullType(GetAdminBannerStatistics200ResponseRangeTimezoneEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseRange object, {
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
    required GetAdminBannerStatistics200ResponseRangeBuilder result,
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
                GetAdminBannerStatistics200ResponseRangeTimezoneEnum),
          ) as GetAdminBannerStatistics200ResponseRangeTimezoneEnum;
          result.timezone = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminBannerStatistics200ResponseRange deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminBannerStatistics200ResponseRangeBuilder();
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

class GetAdminBannerStatistics200ResponseRangeTimezoneEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Asia/Shanghai')
  static const GetAdminBannerStatistics200ResponseRangeTimezoneEnum
      asiaSlashShanghai =
      _$getAdminBannerStatistics200ResponseRangeTimezoneEnum_asiaSlashShanghai;

  static Serializer<GetAdminBannerStatistics200ResponseRangeTimezoneEnum>
      get serializer =>
          _$getAdminBannerStatistics200ResponseRangeTimezoneEnumSerializer;

  const GetAdminBannerStatistics200ResponseRangeTimezoneEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminBannerStatistics200ResponseRangeTimezoneEnum>
      get values =>
          _$getAdminBannerStatistics200ResponseRangeTimezoneEnumValues;
  static GetAdminBannerStatistics200ResponseRangeTimezoneEnum valueOf(
          String name) =>
      _$getAdminBannerStatistics200ResponseRangeTimezoneEnumValueOf(name);
}
