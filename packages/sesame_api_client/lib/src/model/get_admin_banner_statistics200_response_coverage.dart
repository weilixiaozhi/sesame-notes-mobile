//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_banner_statistics200_response_coverage.g.dart';

/// GetAdminBannerStatistics200ResponseCoverage
///
/// Properties:
/// * [collectionStartedAt]
/// * [complete]
/// * [audience]
@BuiltValue()
abstract class GetAdminBannerStatistics200ResponseCoverage
    implements
        Built<GetAdminBannerStatistics200ResponseCoverage,
            GetAdminBannerStatistics200ResponseCoverageBuilder> {
  @BuiltValueField(wireName: r'collection_started_at')
  DateTime get collectionStartedAt;

  @BuiltValueField(wireName: r'complete')
  bool get complete;

  @BuiltValueField(wireName: r'audience')
  GetAdminBannerStatistics200ResponseCoverageAudienceEnum get audience;
  // enum audienceEnum {  authenticated_users,  };

  GetAdminBannerStatistics200ResponseCoverage._();

  factory GetAdminBannerStatistics200ResponseCoverage(
          [void updates(
              GetAdminBannerStatistics200ResponseCoverageBuilder b)]) =
      _$GetAdminBannerStatistics200ResponseCoverage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminBannerStatistics200ResponseCoverageBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminBannerStatistics200ResponseCoverage>
      get serializer =>
          _$GetAdminBannerStatistics200ResponseCoverageSerializer();
}

class _$GetAdminBannerStatistics200ResponseCoverageSerializer
    implements
        PrimitiveSerializer<GetAdminBannerStatistics200ResponseCoverage> {
  @override
  final Iterable<Type> types = const [
    GetAdminBannerStatistics200ResponseCoverage,
    _$GetAdminBannerStatistics200ResponseCoverage
  ];

  @override
  final String wireName = r'GetAdminBannerStatistics200ResponseCoverage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseCoverage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'collection_started_at';
    yield serializers.serialize(
      object.collectionStartedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'complete';
    yield serializers.serialize(
      object.complete,
      specifiedType: const FullType(bool),
    );
    yield r'audience';
    yield serializers.serialize(
      object.audience,
      specifiedType: const FullType(
          GetAdminBannerStatistics200ResponseCoverageAudienceEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseCoverage object, {
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
    required GetAdminBannerStatistics200ResponseCoverageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'collection_started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.collectionStartedAt = valueDes;
          break;
        case r'complete':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.complete = valueDes;
          break;
        case r'audience':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminBannerStatistics200ResponseCoverageAudienceEnum),
          ) as GetAdminBannerStatistics200ResponseCoverageAudienceEnum;
          result.audience = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminBannerStatistics200ResponseCoverage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminBannerStatistics200ResponseCoverageBuilder();
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

class GetAdminBannerStatistics200ResponseCoverageAudienceEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'authenticated_users')
  static const GetAdminBannerStatistics200ResponseCoverageAudienceEnum
      authenticatedUsers =
      _$getAdminBannerStatistics200ResponseCoverageAudienceEnum_authenticatedUsers;

  static Serializer<GetAdminBannerStatistics200ResponseCoverageAudienceEnum>
      get serializer =>
          _$getAdminBannerStatistics200ResponseCoverageAudienceEnumSerializer;

  const GetAdminBannerStatistics200ResponseCoverageAudienceEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminBannerStatistics200ResponseCoverageAudienceEnum>
      get values =>
          _$getAdminBannerStatistics200ResponseCoverageAudienceEnumValues;
  static GetAdminBannerStatistics200ResponseCoverageAudienceEnum valueOf(
          String name) =>
      _$getAdminBannerStatistics200ResponseCoverageAudienceEnumValueOf(name);
}
