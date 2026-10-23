//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_auth_login200_response_admin_group.g.dart';

/// PostAdminAuthLogin200ResponseAdminGroup
///
/// Properties:
/// * [id]
/// * [name]
/// * [isEnabled]
/// * [isDefault]
/// * [version]
@BuiltValue()
abstract class PostAdminAuthLogin200ResponseAdminGroup
    implements
        Built<PostAdminAuthLogin200ResponseAdminGroup,
            PostAdminAuthLogin200ResponseAdminGroupBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'is_default')
  bool get isDefault;

  @BuiltValueField(wireName: r'version')
  int get version;

  PostAdminAuthLogin200ResponseAdminGroup._();

  factory PostAdminAuthLogin200ResponseAdminGroup(
          [void updates(PostAdminAuthLogin200ResponseAdminGroupBuilder b)]) =
      _$PostAdminAuthLogin200ResponseAdminGroup;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAuthLogin200ResponseAdminGroupBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAuthLogin200ResponseAdminGroup> get serializer =>
      _$PostAdminAuthLogin200ResponseAdminGroupSerializer();
}

class _$PostAdminAuthLogin200ResponseAdminGroupSerializer
    implements PrimitiveSerializer<PostAdminAuthLogin200ResponseAdminGroup> {
  @override
  final Iterable<Type> types = const [
    PostAdminAuthLogin200ResponseAdminGroup,
    _$PostAdminAuthLogin200ResponseAdminGroup
  ];

  @override
  final String wireName = r'PostAdminAuthLogin200ResponseAdminGroup';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAuthLogin200ResponseAdminGroup object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'is_default';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAuthLogin200ResponseAdminGroup object, {
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
    required PostAdminAuthLogin200ResponseAdminGroupBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAuthLogin200ResponseAdminGroup deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAuthLogin200ResponseAdminGroupBuilder();
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
