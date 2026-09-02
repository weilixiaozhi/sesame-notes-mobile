//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_invites_by_code_accept200_response.g.dart';

/// PostInvitesByCodeAccept200Response
///
/// Properties:
/// * [ledgerId]
/// * [ledgerName]
/// * [role]
@BuiltValue()
abstract class PostInvitesByCodeAccept200Response
    implements
        Built<PostInvitesByCodeAccept200Response,
            PostInvitesByCodeAccept200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'ledger_name')
  String get ledgerName;

  @BuiltValueField(wireName: r'role')
  PostInvitesByCodeAccept200ResponseRoleEnum get role;
  // enum roleEnum {  editor,  };

  PostInvitesByCodeAccept200Response._();

  factory PostInvitesByCodeAccept200Response(
          [void updates(PostInvitesByCodeAccept200ResponseBuilder b)]) =
      _$PostInvitesByCodeAccept200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostInvitesByCodeAccept200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostInvitesByCodeAccept200Response> get serializer =>
      _$PostInvitesByCodeAccept200ResponseSerializer();
}

class _$PostInvitesByCodeAccept200ResponseSerializer
    implements PrimitiveSerializer<PostInvitesByCodeAccept200Response> {
  @override
  final Iterable<Type> types = const [
    PostInvitesByCodeAccept200Response,
    _$PostInvitesByCodeAccept200Response
  ];

  @override
  final String wireName = r'PostInvitesByCodeAccept200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostInvitesByCodeAccept200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_name';
    yield serializers.serialize(
      object.ledgerName,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(PostInvitesByCodeAccept200ResponseRoleEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostInvitesByCodeAccept200Response object, {
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
    required PostInvitesByCodeAccept200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'ledger_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerName = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostInvitesByCodeAccept200ResponseRoleEnum),
          ) as PostInvitesByCodeAccept200ResponseRoleEnum;
          result.role = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostInvitesByCodeAccept200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostInvitesByCodeAccept200ResponseBuilder();
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

class PostInvitesByCodeAccept200ResponseRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editor')
  static const PostInvitesByCodeAccept200ResponseRoleEnum editor =
      _$postInvitesByCodeAccept200ResponseRoleEnum_editor;

  static Serializer<PostInvitesByCodeAccept200ResponseRoleEnum>
      get serializer => _$postInvitesByCodeAccept200ResponseRoleEnumSerializer;

  const PostInvitesByCodeAccept200ResponseRoleEnum._(String name) : super(name);

  static BuiltSet<PostInvitesByCodeAccept200ResponseRoleEnum> get values =>
      _$postInvitesByCodeAccept200ResponseRoleEnumValues;
  static PostInvitesByCodeAccept200ResponseRoleEnum valueOf(String name) =>
      _$postInvitesByCodeAccept200ResponseRoleEnumValueOf(name);
}
