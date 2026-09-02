//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_profile_me200_response.g.dart';

/// GetProfileMe200Response
///
/// Properties:
/// * [userId]
/// * [sesameNumber]
/// * [displayName]
/// * [avatarUrl]
/// * [avatarVersion]
/// * [phoneMasked]
/// * [gender]
/// * [isAdmin]
/// * [incomeIsRed]
/// * [themePrimaryColor]
/// * [appearance]
/// * [aiConfig]
/// * [primaryCurrency]
@BuiltValue()
abstract class GetProfileMe200Response
    implements Built<GetProfileMe200Response, GetProfileMe200ResponseBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'sesame_number')
  String? get sesameNumber;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'phone_masked')
  String? get phoneMasked;

  @BuiltValueField(wireName: r'gender')
  GetProfileMe200ResponseGenderEnum get gender;
  // enum genderEnum {  UNSPECIFIED,  MALE,  FEMALE,  };

  @BuiltValueField(wireName: r'is_admin')
  bool get isAdmin;

  @BuiltValueField(wireName: r'income_is_red')
  bool? get incomeIsRed;

  @BuiltValueField(wireName: r'theme_primary_color')
  String? get themePrimaryColor;

  @BuiltValueField(wireName: r'appearance')
  BuiltMap<String, JsonObject?>? get appearance;

  @BuiltValueField(wireName: r'ai_config')
  BuiltMap<String, JsonObject?>? get aiConfig;

  @BuiltValueField(wireName: r'primary_currency')
  String? get primaryCurrency;

  GetProfileMe200Response._();

  factory GetProfileMe200Response(
          [void updates(GetProfileMe200ResponseBuilder b)]) =
      _$GetProfileMe200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetProfileMe200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetProfileMe200Response> get serializer =>
      _$GetProfileMe200ResponseSerializer();
}

class _$GetProfileMe200ResponseSerializer
    implements PrimitiveSerializer<GetProfileMe200Response> {
  @override
  final Iterable<Type> types = const [
    GetProfileMe200Response,
    _$GetProfileMe200Response
  ];

  @override
  final String wireName = r'GetProfileMe200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetProfileMe200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'sesame_number';
    yield object.sesameNumber == null
        ? null
        : serializers.serialize(
            object.sesameNumber,
            specifiedType: const FullType.nullable(String),
          );
    yield r'display_name';
    yield object.displayName == null
        ? null
        : serializers.serialize(
            object.displayName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'avatar_url';
    yield object.avatarUrl == null
        ? null
        : serializers.serialize(
            object.avatarUrl,
            specifiedType: const FullType.nullable(String),
          );
    yield r'avatar_version';
    yield serializers.serialize(
      object.avatarVersion,
      specifiedType: const FullType(int),
    );
    yield r'phone_masked';
    yield object.phoneMasked == null
        ? null
        : serializers.serialize(
            object.phoneMasked,
            specifiedType: const FullType.nullable(String),
          );
    yield r'gender';
    yield serializers.serialize(
      object.gender,
      specifiedType: const FullType(GetProfileMe200ResponseGenderEnum),
    );
    yield r'is_admin';
    yield serializers.serialize(
      object.isAdmin,
      specifiedType: const FullType(bool),
    );
    yield r'income_is_red';
    yield object.incomeIsRed == null
        ? null
        : serializers.serialize(
            object.incomeIsRed,
            specifiedType: const FullType.nullable(bool),
          );
    yield r'theme_primary_color';
    yield object.themePrimaryColor == null
        ? null
        : serializers.serialize(
            object.themePrimaryColor,
            specifiedType: const FullType.nullable(String),
          );
    yield r'appearance';
    yield object.appearance == null
        ? null
        : serializers.serialize(
            object.appearance,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'ai_config';
    yield object.aiConfig == null
        ? null
        : serializers.serialize(
            object.aiConfig,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'primary_currency';
    yield object.primaryCurrency == null
        ? null
        : serializers.serialize(
            object.primaryCurrency,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetProfileMe200Response object, {
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
    required GetProfileMe200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'sesame_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sesameNumber = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatarUrl = valueDes;
          break;
        case r'avatar_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avatarVersion = valueDes;
          break;
        case r'phone_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phoneMasked = valueDes;
          break;
        case r'gender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetProfileMe200ResponseGenderEnum),
          ) as GetProfileMe200ResponseGenderEnum;
          result.gender = valueDes;
          break;
        case r'is_admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isAdmin = valueDes;
          break;
        case r'income_is_red':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.incomeIsRed = valueDes;
          break;
        case r'theme_primary_color':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.themePrimaryColor = valueDes;
          break;
        case r'appearance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.appearance.replace(valueDes);
          break;
        case r'ai_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.aiConfig.replace(valueDes);
          break;
        case r'primary_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryCurrency = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetProfileMe200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetProfileMe200ResponseBuilder();
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

class GetProfileMe200ResponseGenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UNSPECIFIED')
  static const GetProfileMe200ResponseGenderEnum UNSPECIFIED =
      _$getProfileMe200ResponseGenderEnum_UNSPECIFIED;
  @BuiltValueEnumConst(wireName: r'MALE')
  static const GetProfileMe200ResponseGenderEnum MALE =
      _$getProfileMe200ResponseGenderEnum_MALE;
  @BuiltValueEnumConst(wireName: r'FEMALE')
  static const GetProfileMe200ResponseGenderEnum FEMALE =
      _$getProfileMe200ResponseGenderEnum_FEMALE;

  static Serializer<GetProfileMe200ResponseGenderEnum> get serializer =>
      _$getProfileMe200ResponseGenderEnumSerializer;

  const GetProfileMe200ResponseGenderEnum._(String name) : super(name);

  static BuiltSet<GetProfileMe200ResponseGenderEnum> get values =>
      _$getProfileMe200ResponseGenderEnumValues;
  static GetProfileMe200ResponseGenderEnum valueOf(String name) =>
      _$getProfileMe200ResponseGenderEnumValueOf(name);
}
