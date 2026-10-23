//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics200_response_series_inner.g.dart';

/// GetAdminAnalytics200ResponseSeriesInner
///
/// Properties:
/// * [periodStart]
/// * [newUsers]
/// * [activeUsers]
/// * [pageViews]
@BuiltValue()
abstract class GetAdminAnalytics200ResponseSeriesInner
    implements
        Built<GetAdminAnalytics200ResponseSeriesInner,
            GetAdminAnalytics200ResponseSeriesInnerBuilder> {
  @BuiltValueField(wireName: r'period_start')
  DateTime get periodStart;

  @BuiltValueField(wireName: r'new_users')
  int get newUsers;

  @BuiltValueField(wireName: r'active_users')
  int get activeUsers;

  @BuiltValueField(wireName: r'page_views')
  int get pageViews;

  GetAdminAnalytics200ResponseSeriesInner._();

  factory GetAdminAnalytics200ResponseSeriesInner(
          [void updates(GetAdminAnalytics200ResponseSeriesInnerBuilder b)]) =
      _$GetAdminAnalytics200ResponseSeriesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalytics200ResponseSeriesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalytics200ResponseSeriesInner> get serializer =>
      _$GetAdminAnalytics200ResponseSeriesInnerSerializer();
}

class _$GetAdminAnalytics200ResponseSeriesInnerSerializer
    implements PrimitiveSerializer<GetAdminAnalytics200ResponseSeriesInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalytics200ResponseSeriesInner,
    _$GetAdminAnalytics200ResponseSeriesInner
  ];

  @override
  final String wireName = r'GetAdminAnalytics200ResponseSeriesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalytics200ResponseSeriesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'period_start';
    yield serializers.serialize(
      object.periodStart,
      specifiedType: const FullType(DateTime),
    );
    yield r'new_users';
    yield serializers.serialize(
      object.newUsers,
      specifiedType: const FullType(int),
    );
    yield r'active_users';
    yield serializers.serialize(
      object.activeUsers,
      specifiedType: const FullType(int),
    );
    yield r'page_views';
    yield serializers.serialize(
      object.pageViews,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalytics200ResponseSeriesInner object, {
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
    required GetAdminAnalytics200ResponseSeriesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'period_start':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.periodStart = valueDes;
          break;
        case r'new_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.newUsers = valueDes;
          break;
        case r'active_users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.activeUsers = valueDes;
          break;
        case r'page_views':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageViews = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalytics200ResponseSeriesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalytics200ResponseSeriesInnerBuilder();
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
