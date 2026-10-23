//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_admin_groups_by_group_id_request.g.dart';

/// DeleteAdminGroupsByGroupIdRequest
///
/// Properties:
/// * [version]
/// * [reason]
@BuiltValue()
abstract class DeleteAdminGroupsByGroupIdRequest
    implements
        Built<DeleteAdminGroupsByGroupIdRequest,
            DeleteAdminGroupsByGroupIdRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  DeleteAdminGroupsByGroupIdRequest._();

  factory DeleteAdminGroupsByGroupIdRequest(
          [void updates(DeleteAdminGroupsByGroupIdRequestBuilder b)]) =
      _$DeleteAdminGroupsByGroupIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAdminGroupsByGroupIdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAdminGroupsByGroupIdRequest> get serializer =>
      _$DeleteAdminGroupsByGroupIdRequestSerializer();
}

class _$DeleteAdminGroupsByGroupIdRequestSerializer
    implements PrimitiveSerializer<DeleteAdminGroupsByGroupIdRequest> {
  @override
  final Iterable<Type> types = const [
    DeleteAdminGroupsByGroupIdRequest,
    _$DeleteAdminGroupsByGroupIdRequest
  ];

  @override
  final String wireName = r'DeleteAdminGroupsByGroupIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAdminGroupsByGroupIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteAdminGroupsByGroupIdRequest object, {
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
    required DeleteAdminGroupsByGroupIdRequestBuilder result,
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
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
  DeleteAdminGroupsByGroupIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAdminGroupsByGroupIdRequestBuilder();
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
