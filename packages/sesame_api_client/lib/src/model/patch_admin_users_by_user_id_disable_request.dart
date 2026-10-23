//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_users_by_user_id_disable_request.g.dart';

/// PatchAdminUsersByUserIdDisableRequest
///
/// Properties:
/// * [reason]
@BuiltValue()
abstract class PatchAdminUsersByUserIdDisableRequest
    implements
        Built<PatchAdminUsersByUserIdDisableRequest,
            PatchAdminUsersByUserIdDisableRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  PatchAdminUsersByUserIdDisableRequest._();

  factory PatchAdminUsersByUserIdDisableRequest(
          [void updates(PatchAdminUsersByUserIdDisableRequestBuilder b)]) =
      _$PatchAdminUsersByUserIdDisableRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAdminUsersByUserIdDisableRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminUsersByUserIdDisableRequest> get serializer =>
      _$PatchAdminUsersByUserIdDisableRequestSerializer();
}

class _$PatchAdminUsersByUserIdDisableRequestSerializer
    implements PrimitiveSerializer<PatchAdminUsersByUserIdDisableRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAdminUsersByUserIdDisableRequest,
    _$PatchAdminUsersByUserIdDisableRequest
  ];

  @override
  final String wireName = r'PatchAdminUsersByUserIdDisableRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminUsersByUserIdDisableRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchAdminUsersByUserIdDisableRequest object, {
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
    required PatchAdminUsersByUserIdDisableRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  PatchAdminUsersByUserIdDisableRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminUsersByUserIdDisableRequestBuilder();
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
