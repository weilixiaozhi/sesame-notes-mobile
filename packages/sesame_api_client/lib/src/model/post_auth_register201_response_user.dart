//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_register201_response_user.g.dart';

/// PostAuthRegister201ResponseUser
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
@BuiltValue()
abstract class PostAuthRegister201ResponseUser
    implements
        Built<PostAuthRegister201ResponseUser,
            PostAuthRegister201ResponseUserBuilder> {
  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'sesame_number')
  String get sesameNumber;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'avatar_url')
  String? get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'phone_masked')
  String? get phoneMasked;

  @BuiltValueField(wireName: r'gender')
  PostAuthRegister201ResponseUserGenderEnum get gender;
  // enum genderEnum {  UNSPECIFIED,  MALE,  FEMALE,  };

  @BuiltValueField(wireName: r'is_admin')
  bool get isAdmin;

  PostAuthRegister201ResponseUser._();

  factory PostAuthRegister201ResponseUser(
          [void updates(PostAuthRegister201ResponseUserBuilder b)]) =
      _$PostAuthRegister201ResponseUser;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthRegister201ResponseUserBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthRegister201ResponseUser> get serializer =>
      _$PostAuthRegister201ResponseUserSerializer();
}

class _$PostAuthRegister201ResponseUserSerializer
    implements PrimitiveSerializer<PostAuthRegister201ResponseUser> {
  @override
  final Iterable<Type> types = const [
    PostAuthRegister201ResponseUser,
    _$PostAuthRegister201ResponseUser
  ];

  @override
  final String wireName = r'PostAuthRegister201ResponseUser';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthRegister201ResponseUser object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'sesame_number';
    yield serializers.serialize(
      object.sesameNumber,
      specifiedType: const FullType(String),
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
      specifiedType: const FullType(PostAuthRegister201ResponseUserGenderEnum),
    );
    yield r'is_admin';
    yield serializers.serialize(
      object.isAdmin,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthRegister201ResponseUser object, {
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
    required PostAuthRegister201ResponseUserBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType:
                const FullType(PostAuthRegister201ResponseUserGenderEnum),
          ) as PostAuthRegister201ResponseUserGenderEnum;
          result.gender = valueDes;
          break;
        case r'is_admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isAdmin = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthRegister201ResponseUser deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthRegister201ResponseUserBuilder();
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

class PostAuthRegister201ResponseUserGenderEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'UNSPECIFIED')
  static const PostAuthRegister201ResponseUserGenderEnum UNSPECIFIED =
      _$postAuthRegister201ResponseUserGenderEnum_UNSPECIFIED;
  @BuiltValueEnumConst(wireName: r'MALE')
  static const PostAuthRegister201ResponseUserGenderEnum MALE =
      _$postAuthRegister201ResponseUserGenderEnum_MALE;
  @BuiltValueEnumConst(wireName: r'FEMALE')
  static const PostAuthRegister201ResponseUserGenderEnum FEMALE =
      _$postAuthRegister201ResponseUserGenderEnum_FEMALE;

  static Serializer<PostAuthRegister201ResponseUserGenderEnum> get serializer =>
      _$postAuthRegister201ResponseUserGenderEnumSerializer;

  const PostAuthRegister201ResponseUserGenderEnum._(String name) : super(name);

  static BuiltSet<PostAuthRegister201ResponseUserGenderEnum> get values =>
      _$postAuthRegister201ResponseUserGenderEnumValues;
  static PostAuthRegister201ResponseUserGenderEnum valueOf(String name) =>
      _$postAuthRegister201ResponseUserGenderEnumValueOf(name);
}
