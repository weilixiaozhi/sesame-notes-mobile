//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_groups_request.g.dart';

/// PostAdminGroupsRequest
///
/// Properties:
/// * [name]
/// * [description]
/// * [sort]
/// * [isEnabled]
@BuiltValue()
abstract class PostAdminGroupsRequest
    implements Built<PostAdminGroupsRequest, PostAdminGroupsRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'sort')
  int? get sort;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  PostAdminGroupsRequest._();

  factory PostAdminGroupsRequest(
          [void updates(PostAdminGroupsRequestBuilder b)]) =
      _$PostAdminGroupsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminGroupsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminGroupsRequest> get serializer =>
      _$PostAdminGroupsRequestSerializer();
}

class _$PostAdminGroupsRequestSerializer
    implements PrimitiveSerializer<PostAdminGroupsRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminGroupsRequest,
    _$PostAdminGroupsRequest
  ];

  @override
  final String wireName = r'PostAdminGroupsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminGroupsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.sort != null) {
      yield r'sort';
      yield serializers.serialize(
        object.sort,
        specifiedType: const FullType(int),
      );
    }
    if (object.isEnabled != null) {
      yield r'is_enabled';
      yield serializers.serialize(
        object.isEnabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminGroupsRequest object, {
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
    required PostAdminGroupsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'sort':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sort = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminGroupsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminGroupsRequestBuilder();
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
