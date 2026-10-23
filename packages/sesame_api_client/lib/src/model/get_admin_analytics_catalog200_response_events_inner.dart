//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_analytics_catalog200_response_events_inner_source_pages_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_catalog200_response_events_inner.g.dart';

/// GetAdminAnalyticsCatalog200ResponseEventsInner
///
/// Properties:
/// * [id]
/// * [eventName]
/// * [pageId]
/// * [kind]
/// * [behavior]
/// * [name]
/// * [location]
/// * [platforms]
/// * [sourcePages]
@BuiltValue()
abstract class GetAdminAnalyticsCatalog200ResponseEventsInner
    implements
        Built<GetAdminAnalyticsCatalog200ResponseEventsInner,
            GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'event_name')
  String get eventName;

  @BuiltValueField(wireName: r'page_id')
  String? get pageId;

  @BuiltValueField(wireName: r'kind')
  GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum get kind;
  // enum kindEnum {  page_view,  action,  };

  @BuiltValueField(wireName: r'behavior')
  GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum get behavior;
  // enum behaviorEnum {  view,  click,  complete,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'location')
  String get location;

  @BuiltValueField(wireName: r'platforms')
  BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
      get platforms;
  // enum platformsEnum {  app,  web,  };

  @BuiltValueField(wireName: r'source_pages')
  BuiltList<GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>
      get sourcePages;

  GetAdminAnalyticsCatalog200ResponseEventsInner._();

  factory GetAdminAnalyticsCatalog200ResponseEventsInner(
          [void updates(
              GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder b)]) =
      _$GetAdminAnalyticsCatalog200ResponseEventsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsCatalog200ResponseEventsInner>
      get serializer =>
          _$GetAdminAnalyticsCatalog200ResponseEventsInnerSerializer();
}

class _$GetAdminAnalyticsCatalog200ResponseEventsInnerSerializer
    implements
        PrimitiveSerializer<GetAdminAnalyticsCatalog200ResponseEventsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsCatalog200ResponseEventsInner,
    _$GetAdminAnalyticsCatalog200ResponseEventsInner
  ];

  @override
  final String wireName = r'GetAdminAnalyticsCatalog200ResponseEventsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsCatalog200ResponseEventsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'event_name';
    yield serializers.serialize(
      object.eventName,
      specifiedType: const FullType(String),
    );
    yield r'page_id';
    yield object.pageId == null
        ? null
        : serializers.serialize(
            object.pageId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum),
    );
    yield r'behavior';
    yield serializers.serialize(
      object.behavior,
      specifiedType: const FullType(
          GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'location';
    yield serializers.serialize(
      object.location,
      specifiedType: const FullType(String),
    );
    yield r'platforms';
    yield serializers.serialize(
      object.platforms,
      specifiedType: const FullType(BuiltSet, [
        FullType(GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum)
      ]),
    );
    yield r'source_pages';
    yield serializers.serialize(
      object.sourcePages,
      specifiedType: const FullType(BuiltList, [
        FullType(GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsCatalog200ResponseEventsInner object, {
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
    required GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'event_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventName = valueDes;
          break;
        case r'page_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.pageId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum),
          ) as GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'behavior':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum),
          ) as GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum;
          result.behavior = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.location = valueDes;
          break;
        case r'platforms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [
              FullType(
                  GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum)
            ]),
          ) as BuiltSet<
              GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>;
          result.platforms.replace(valueDes);
          break;
        case r'source_pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner)
            ]),
          ) as BuiltList<
              GetAdminAnalyticsCatalog200ResponseEventsInnerSourcePagesInner>;
          result.sourcePages.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalyticsCatalog200ResponseEventsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsCatalog200ResponseEventsInnerBuilder();
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

class GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'page_view')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum pageView =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_pageView;
  @BuiltValueEnumConst(wireName: r'action')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum action =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnum_action;

  static Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>
      get serializer =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumSerializer;

  const GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum>
      get values =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumValues;
  static GetAdminAnalyticsCatalog200ResponseEventsInnerKindEnum valueOf(
          String name) =>
      _$getAdminAnalyticsCatalog200ResponseEventsInnerKindEnumValueOf(name);
}

class GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'view')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum view =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_view;
  @BuiltValueEnumConst(wireName: r'click')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
      click =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_click;
  @BuiltValueEnumConst(wireName: r'complete')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum
      complete =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum_complete;

  static Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>
      get serializer =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumSerializer;

  const GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum._(
      String name)
      : super(name);

  static BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum>
      get values =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumValues;
  static GetAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnum valueOf(
          String name) =>
      _$getAdminAnalyticsCatalog200ResponseEventsInnerBehaviorEnumValueOf(name);
}

class GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'app')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum app =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_app;
  @BuiltValueEnumConst(wireName: r'web')
  static const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum web =
      _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum_web;

  static Serializer<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
      get serializer =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumSerializer;

  const GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum._(
      String name)
      : super(name);

  static BuiltSet<GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum>
      get values =>
          _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumValues;
  static GetAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnum valueOf(
          String name) =>
      _$getAdminAnalyticsCatalog200ResponseEventsInnerPlatformsEnumValueOf(
          name);
}
