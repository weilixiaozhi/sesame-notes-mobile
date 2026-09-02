//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_invites201_response.g.dart';

/// PostLedgersByLedgerIdInvites201Response
///
/// Properties:
/// * [id]
/// * [codePrefix]
/// * [role]
/// * [expiresAt]
/// * [usedAt]
/// * [usedByUserId]
/// * [createdAt]
/// * [code]
@BuiltValue()
abstract class PostLedgersByLedgerIdInvites201Response
    implements
        Built<PostLedgersByLedgerIdInvites201Response,
            PostLedgersByLedgerIdInvites201ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'code_prefix')
  String get codePrefix;

  @BuiltValueField(wireName: r'role')
  PostLedgersByLedgerIdInvites201ResponseRoleEnum get role;
  // enum roleEnum {  editor,  };

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'used_at')
  DateTime? get usedAt;

  @BuiltValueField(wireName: r'used_by_user_id')
  String? get usedByUserId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'code')
  String get code;

  PostLedgersByLedgerIdInvites201Response._();

  factory PostLedgersByLedgerIdInvites201Response(
          [void updates(PostLedgersByLedgerIdInvites201ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdInvites201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdInvites201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdInvites201Response> get serializer =>
      _$PostLedgersByLedgerIdInvites201ResponseSerializer();
}

class _$PostLedgersByLedgerIdInvites201ResponseSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdInvites201Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdInvites201Response,
    _$PostLedgersByLedgerIdInvites201Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdInvites201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdInvites201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'code_prefix';
    yield serializers.serialize(
      object.codePrefix,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType:
          const FullType(PostLedgersByLedgerIdInvites201ResponseRoleEnum),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'used_at';
    yield object.usedAt == null
        ? null
        : serializers.serialize(
            object.usedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'used_by_user_id';
    yield object.usedByUserId == null
        ? null
        : serializers.serialize(
            object.usedByUserId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdInvites201Response object, {
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
    required PostLedgersByLedgerIdInvites201ResponseBuilder result,
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
        case r'code_prefix':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.codePrefix = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostLedgersByLedgerIdInvites201ResponseRoleEnum),
          ) as PostLedgersByLedgerIdInvites201ResponseRoleEnum;
          result.role = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'used_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.usedAt = valueDes;
          break;
        case r'used_by_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.usedByUserId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdInvites201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdInvites201ResponseBuilder();
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

class PostLedgersByLedgerIdInvites201ResponseRoleEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'editor')
  static const PostLedgersByLedgerIdInvites201ResponseRoleEnum editor =
      _$postLedgersByLedgerIdInvites201ResponseRoleEnum_editor;

  static Serializer<PostLedgersByLedgerIdInvites201ResponseRoleEnum>
      get serializer =>
          _$postLedgersByLedgerIdInvites201ResponseRoleEnumSerializer;

  const PostLedgersByLedgerIdInvites201ResponseRoleEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdInvites201ResponseRoleEnum> get values =>
      _$postLedgersByLedgerIdInvites201ResponseRoleEnumValues;
  static PostLedgersByLedgerIdInvites201ResponseRoleEnum valueOf(String name) =>
      _$postLedgersByLedgerIdInvites201ResponseRoleEnumValueOf(name);
}
