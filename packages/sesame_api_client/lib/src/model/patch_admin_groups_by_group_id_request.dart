//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_groups_by_group_id_request.g.dart';

/// PatchAdminGroupsByGroupIdRequest
///
/// Properties:
/// * [version]
/// * [name]
/// * [description]
/// * [sort]
/// * [isEnabled]
/// * [reason]
@BuiltValue()
abstract class PatchAdminGroupsByGroupIdRequest
    implements
        Built<PatchAdminGroupsByGroupIdRequest,
            PatchAdminGroupsByGroupIdRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'sort')
  int? get sort;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  PatchAdminGroupsByGroupIdRequest._();

  factory PatchAdminGroupsByGroupIdRequest(
          [void updates(PatchAdminGroupsByGroupIdRequestBuilder b)]) =
      _$PatchAdminGroupsByGroupIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAdminGroupsByGroupIdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminGroupsByGroupIdRequest> get serializer =>
      _$PatchAdminGroupsByGroupIdRequestSerializer();
}

class _$PatchAdminGroupsByGroupIdRequestSerializer
    implements PrimitiveSerializer<PatchAdminGroupsByGroupIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAdminGroupsByGroupIdRequest,
    _$PatchAdminGroupsByGroupIdRequest
  ];

  @override
  final String wireName = r'PatchAdminGroupsByGroupIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminGroupsByGroupIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchAdminGroupsByGroupIdRequest object, {
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
    required PatchAdminGroupsByGroupIdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchAdminGroupsByGroupIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminGroupsByGroupIdRequestBuilder();
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
