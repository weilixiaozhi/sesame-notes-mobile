//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_auth_register201_response_user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_register201_response.g.dart';

/// PostAuthRegister201Response
///
/// Properties:
/// * [accessToken]
/// * [refreshToken]
/// * [tokenType]
/// * [expiresIn]
/// * [deviceId]
/// * [scopes]
/// * [user]
@BuiltValue()
abstract class PostAuthRegister201Response
    implements
        Built<PostAuthRegister201Response, PostAuthRegister201ResponseBuilder> {
  @BuiltValueField(wireName: r'access_token')
  String get accessToken;

  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  @BuiltValueField(wireName: r'token_type')
  PostAuthRegister201ResponseTokenTypeEnum get tokenType;
  // enum tokenTypeEnum {  Bearer,  };

  @BuiltValueField(wireName: r'expires_in')
  int get expiresIn;

  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  @BuiltValueField(wireName: r'scopes')
  BuiltList<String> get scopes;

  @BuiltValueField(wireName: r'user')
  PostAuthRegister201ResponseUser get user;

  PostAuthRegister201Response._();

  factory PostAuthRegister201Response(
          [void updates(PostAuthRegister201ResponseBuilder b)]) =
      _$PostAuthRegister201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthRegister201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthRegister201Response> get serializer =>
      _$PostAuthRegister201ResponseSerializer();
}

class _$PostAuthRegister201ResponseSerializer
    implements PrimitiveSerializer<PostAuthRegister201Response> {
  @override
  final Iterable<Type> types = const [
    PostAuthRegister201Response,
    _$PostAuthRegister201Response
  ];

  @override
  final String wireName = r'PostAuthRegister201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthRegister201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'access_token';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    yield r'token_type';
    yield serializers.serialize(
      object.tokenType,
      specifiedType: const FullType(PostAuthRegister201ResponseTokenTypeEnum),
    );
    yield r'expires_in';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(int),
    );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'scopes';
    yield serializers.serialize(
      object.scopes,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(PostAuthRegister201ResponseUser),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthRegister201Response object, {
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
    required PostAuthRegister201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'access_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'token_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAuthRegister201ResponseTokenTypeEnum),
          ) as PostAuthRegister201ResponseTokenTypeEnum;
          result.tokenType = valueDes;
          break;
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'scopes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.scopes.replace(valueDes);
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthRegister201ResponseUser),
          ) as PostAuthRegister201ResponseUser;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthRegister201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthRegister201ResponseBuilder();
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

class PostAuthRegister201ResponseTokenTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'Bearer')
  static const PostAuthRegister201ResponseTokenTypeEnum bearer =
      _$postAuthRegister201ResponseTokenTypeEnum_bearer;

  static Serializer<PostAuthRegister201ResponseTokenTypeEnum> get serializer =>
      _$postAuthRegister201ResponseTokenTypeEnumSerializer;

  const PostAuthRegister201ResponseTokenTypeEnum._(String name) : super(name);

  static BuiltSet<PostAuthRegister201ResponseTokenTypeEnum> get values =>
      _$postAuthRegister201ResponseTokenTypeEnumValues;
  static PostAuthRegister201ResponseTokenTypeEnum valueOf(String name) =>
      _$postAuthRegister201ResponseTokenTypeEnumValueOf(name);
}
