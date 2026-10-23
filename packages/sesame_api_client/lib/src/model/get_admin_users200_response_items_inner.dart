//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_users200_response_items_inner.g.dart';

/// GetAdminUsers200ResponseItemsInner
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
@BuiltValue()
abstract class GetAdminUsers200ResponseItemsInner
    implements
        Built<GetAdminUsers200ResponseItemsInner,
            GetAdminUsers200ResponseItemsInnerBuilder> {
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
  GetAdminUsers200ResponseItemsInnerGenderEnum get gender;
  // enum genderEnum {  UNSPECIFIED,  MALE,  FEMALE,  };

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  GetAdminUsers200ResponseItemsInner._();

  factory GetAdminUsers200ResponseItemsInner(
          [void updates(GetAdminUsers200ResponseItemsInnerBuilder b)]) =
      _$GetAdminUsers200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminUsers200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminUsers200ResponseItemsInner> get serializer =>
      _$GetAdminUsers200ResponseItemsInnerSerializer();
}

class _$GetAdminUsers200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<GetAdminUsers200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminUsers200ResponseItemsInner,
    _$GetAdminUsers200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminUsers200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminUsers200ResponseItemsInner object, {
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
      specifiedType:
          const FullType(GetAdminUsers200ResponseItemsInnerGenderEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminUsers200ResponseItemsInner object, {
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
    required GetAdminUsers200ResponseItemsInnerBuilder result,
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
                const FullType(GetAdminUsers200ResponseItemsInnerGenderEnum),
          ) as GetAdminUsers200ResponseItemsInnerGenderEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminUsers200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminUsers200ResponseItemsInnerBuilder();
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

class GetAdminUsers200ResponseItemsInnerGenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UNSPECIFIED')
  static const GetAdminUsers200ResponseItemsInnerGenderEnum UNSPECIFIED =
      _$getAdminUsers200ResponseItemsInnerGenderEnum_UNSPECIFIED;
  @BuiltValueEnumConst(wireName: r'MALE')
  static const GetAdminUsers200ResponseItemsInnerGenderEnum MALE =
      _$getAdminUsers200ResponseItemsInnerGenderEnum_MALE;
  @BuiltValueEnumConst(wireName: r'FEMALE')
  static const GetAdminUsers200ResponseItemsInnerGenderEnum FEMALE =
      _$getAdminUsers200ResponseItemsInnerGenderEnum_FEMALE;

  static Serializer<GetAdminUsers200ResponseItemsInnerGenderEnum>
      get serializer =>
          _$getAdminUsers200ResponseItemsInnerGenderEnumSerializer;

  const GetAdminUsers200ResponseItemsInnerGenderEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminUsers200ResponseItemsInnerGenderEnum> get values =>
      _$getAdminUsers200ResponseItemsInnerGenderEnumValues;
  static GetAdminUsers200ResponseItemsInnerGenderEnum valueOf(String name) =>
      _$getAdminUsers200ResponseItemsInnerGenderEnumValueOf(name);
}
