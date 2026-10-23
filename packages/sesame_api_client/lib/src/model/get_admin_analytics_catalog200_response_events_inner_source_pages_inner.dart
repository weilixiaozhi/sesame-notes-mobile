//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_catalog200_response_events_inner_source_pages_inner.g.dart';

/// GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner
///
/// Properties:
/// * [pageId]
/// * [platforms]
@BuiltValue()
abstract class GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner
    implements
        Built<GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner,
            GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder> {
  @BuiltValueField(wireName: r'page_id')
  String get pageId;

  @BuiltValueField(wireName: r'platforms')
  BuiltSet<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
      get platforms;
  // enum platformsEnum {  app,  web,  };

  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner._();

  factory GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner(
          [void updates(
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
                  b)]) =
      _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>
      get serializer =>
          _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerSerializer();
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerSerializer
    implements
        PrimitiveSerializer<
            GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner,
    _$GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner
  ];

  @override
  final String wireName =
      r'GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'page_id';
    yield serializers.serialize(
      object.pageId,
      specifiedType: const FullType(String),
    );
    yield r'platforms';
    yield serializers.serialize(
      object.platforms,
      specifiedType: const FullType(BuiltSet, [
        FullType(
            GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner object, {
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
    required GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'page_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pageId = valueDes;
          break;
        case r'platforms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [
              FullType(
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum)
            ]),
          ) as BuiltSet<
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>;
          result.platforms.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerBuilder();
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

class GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'app')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
      app =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
      web =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum_web;

  static Serializer<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
      get serializer =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumSerializer;

  const GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum>
      get values =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumValues;
  static GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnum
      valueOf(String name) =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInnerPlatformsEnumValueOf(
              name);
}
