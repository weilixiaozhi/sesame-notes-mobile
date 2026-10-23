//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'day_original_date.g.dart';

/// DayOriginalDate
///
/// Properties:
/// * [calendarType]
/// * [originalYear]
/// * [originalMonth]
/// * [originalDay]
/// * [isLeapMonth]
/// * [solarDate]
@BuiltValue()
abstract class DayOriginalDate
    implements Built<DayOriginalDate, DayOriginalDateBuilder> {
  @BuiltValueField(wireName: r'calendar_type')
  DayOriginalDateCalendarTypeEnum get calendarType;
  // enum calendarTypeEnum {  solar,  lunar,  };

  @BuiltValueField(wireName: r'original_year')
  int get originalYear;

  @BuiltValueField(wireName: r'original_month')
  int get originalMonth;

  @BuiltValueField(wireName: r'original_day')
  int get originalDay;

  @BuiltValueField(wireName: r'is_leap_month')
  bool get isLeapMonth;

  @BuiltValueField(wireName: r'solar_date')
  String get solarDate;

  DayOriginalDate._();

  factory DayOriginalDate([void updates(DayOriginalDateBuilder b)]) =
      _$DayOriginalDate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DayOriginalDateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DayOriginalDate> get serializer =>
      _$DayOriginalDateSerializer();
}

class _$DayOriginalDateSerializer
    implements PrimitiveSerializer<DayOriginalDate> {
  @override
  final Iterable<Type> types = const [DayOriginalDate, _$DayOriginalDate];

  @override
  final String wireName = r'DayOriginalDate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DayOriginalDate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'calendar_type';
    yield serializers.serialize(
      object.calendarType,
      specifiedType: const FullType(DayOriginalDateCalendarTypeEnum),
    );
    yield r'original_year';
    yield serializers.serialize(
      object.originalYear,
      specifiedType: const FullType(int),
    );
    yield r'original_month';
    yield serializers.serialize(
      object.originalMonth,
      specifiedType: const FullType(int),
    );
    yield r'original_day';
    yield serializers.serialize(
      object.originalDay,
      specifiedType: const FullType(int),
    );
    yield r'is_leap_month';
    yield serializers.serialize(
      object.isLeapMonth,
      specifiedType: const FullType(bool),
    );
    yield r'solar_date';
    yield serializers.serialize(
      object.solarDate,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DayOriginalDate object, {
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
    required DayOriginalDateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'calendar_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DayOriginalDateCalendarTypeEnum),
          ) as DayOriginalDateCalendarTypeEnum;
          result.calendarType = valueDes;
          break;
        case r'original_year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalYear = valueDes;
          break;
        case r'original_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalMonth = valueDes;
          break;
        case r'original_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalDay = valueDes;
          break;
        case r'is_leap_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isLeapMonth = valueDes;
          break;
        case r'solar_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.solarDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DayOriginalDate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DayOriginalDateBuilder();
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

class DayOriginalDateCalendarTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'solar')
  static const DayOriginalDateCalendarTypeEnum solar =
      _$dayOriginalDateCalendarTypeEnum_solar;
  @BuiltValueEnumConst(wireName: r'lunar')
  static const DayOriginalDateCalendarTypeEnum lunar =
      _$dayOriginalDateCalendarTypeEnum_lunar;

  static Serializer<DayOriginalDateCalendarTypeEnum> get serializer =>
      _$dayOriginalDateCalendarTypeEnumSerializer;

  const DayOriginalDateCalendarTypeEnum._(String name) : super(name);

  static BuiltSet<DayOriginalDateCalendarTypeEnum> get values =>
      _$dayOriginalDateCalendarTypeEnumValues;
  static DayOriginalDateCalendarTypeEnum valueOf(String name) =>
      _$dayOriginalDateCalendarTypeEnumValueOf(name);
}
