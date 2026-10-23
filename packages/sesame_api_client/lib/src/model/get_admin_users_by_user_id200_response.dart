//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_users_by_user_id200_response.g.dart';

/// GetAdminUsersByUserId200Response
///
/// Properties:
/// * [id]
/// * [phone]
/// * [phoneMasked]
/// * [sesameNumber]
/// * [displayName]
/// * [gender]
/// * [avatarUrl]
/// * [avatarVersion]
/// * [isEnabled]
/// * [createdAt]
/// * [profileUpdatedAt]
/// * [primaryCurrency]
/// * [themePrimaryColor]
@BuiltValue()
abstract class GetAdminUsersByUserId200Response
    implements
        Built<GetAdminUsersByUserId200Response,
            GetAdminUsersByUserId200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'phone_masked')
  String? get phoneMasked;

  @BuiltValueField(wireName: r'sesame_number')
  String? get sesameNumber;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'gender')
  GetAdminUsersByUserId200ResponseGenderEnum get gender;
  // enum genderEnum {  UNSPECIFIED,  MALE,  FEMALE,  };

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'profile_updated_at')
  DateTime? get profileUpdatedAt;

  @BuiltValueField(wireName: r'primary_currency')
  String? get primaryCurrency;

  @BuiltValueField(wireName: r'theme_primary_color')
  String? get themePrimaryColor;

  GetAdminUsersByUserId200Response._();

  factory GetAdminUsersByUserId200Response(
          [void updates(GetAdminUsersByUserId200ResponseBuilder b)]) =
      _$GetAdminUsersByUserId200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminUsersByUserId200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminUsersByUserId200Response> get serializer =>
      _$GetAdminUsersByUserId200ResponseSerializer();
}

class _$GetAdminUsersByUserId200ResponseSerializer
    implements PrimitiveSerializer<GetAdminUsersByUserId200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminUsersByUserId200Response,
    _$GetAdminUsersByUserId200Response
  ];

  @override
  final String wireName = r'GetAdminUsersByUserId200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminUsersByUserId200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'phone_masked';
    yield object.phoneMasked == null
        ? null
        : serializers.serialize(
            object.phoneMasked,
            specifiedType: const FullType.nullable(String),
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
    yield r'gender';
    yield serializers.serialize(
      object.gender,
      specifiedType: const FullType(GetAdminUsersByUserId200ResponseGenderEnum),
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
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'profile_updated_at';
    yield object.profileUpdatedAt == null
        ? null
        : serializers.serialize(
            object.profileUpdatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'primary_currency';
    yield object.primaryCurrency == null
        ? null
        : serializers.serialize(
            object.primaryCurrency,
            specifiedType: const FullType.nullable(String),
          );
    yield r'theme_primary_color';
    yield object.themePrimaryColor == null
        ? null
        : serializers.serialize(
            object.themePrimaryColor,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminUsersByUserId200Response object, {
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
    required GetAdminUsersByUserId200ResponseBuilder result,
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
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'phone_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phoneMasked = valueDes;
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
        case r'gender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminUsersByUserId200ResponseGenderEnum),
          ) as GetAdminUsersByUserId200ResponseGenderEnum;
          result.gender = valueDes;
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
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'profile_updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.profileUpdatedAt = valueDes;
          break;
        case r'primary_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryCurrency = valueDes;
          break;
        case r'theme_primary_color':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.themePrimaryColor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminUsersByUserId200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminUsersByUserId200ResponseBuilder();
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

class GetAdminUsersByUserId200ResponseGenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UNSPECIFIED')
  static const GetAdminUsersByUserId200ResponseGenderEnum UNSPECIFIED =
      _$getAdminUsersByUserId200ResponseGenderEnum_UNSPECIFIED;
  @BuiltValueEnumConst(wireName: r'MALE')
  static const GetAdminUsersByUserId200ResponseGenderEnum MALE =
      _$getAdminUsersByUserId200ResponseGenderEnum_MALE;
  @BuiltValueEnumConst(wireName: r'FEMALE')
  static const GetAdminUsersByUserId200ResponseGenderEnum FEMALE =
      _$getAdminUsersByUserId200ResponseGenderEnum_FEMALE;

  static Serializer<GetAdminUsersByUserId200ResponseGenderEnum>
      get serializer => _$getAdminUsersByUserId200ResponseGenderEnumSerializer;

  const GetAdminUsersByUserId200ResponseGenderEnum._(String name) : super(name);

  static BuiltSet<GetAdminUsersByUserId200ResponseGenderEnum> get values =>
      _$getAdminUsersByUserId200ResponseGenderEnumValues;
  static GetAdminUsersByUserId200ResponseGenderEnum valueOf(String name) =>
      _$getAdminUsersByUserId200ResponseGenderEnumValueOf(name);
}
