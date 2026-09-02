//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_auth_password_request.g.dart';

/// PatchAuthPasswordRequest
///
/// Properties:
/// * [currentPassword]
/// * [newPassword]
@BuiltValue()
abstract class PatchAuthPasswordRequest
    implements
        Built<PatchAuthPasswordRequest, PatchAuthPasswordRequestBuilder> {
  @BuiltValueField(wireName: r'current_password')
  String get currentPassword;

  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  PatchAuthPasswordRequest._();

  factory PatchAuthPasswordRequest(
          [void updates(PatchAuthPasswordRequestBuilder b)]) =
      _$PatchAuthPasswordRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAuthPasswordRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAuthPasswordRequest> get serializer =>
      _$PatchAuthPasswordRequestSerializer();
}

class _$PatchAuthPasswordRequestSerializer
    implements PrimitiveSerializer<PatchAuthPasswordRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAuthPasswordRequest,
    _$PatchAuthPasswordRequest
  ];

  @override
  final String wireName = r'PatchAuthPasswordRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAuthPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'current_password';
    yield serializers.serialize(
      object.currentPassword,
      specifiedType: const FullType(String),
    );
    yield r'new_password';
    yield serializers.serialize(
      object.newPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchAuthPasswordRequest object, {
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
    required PatchAuthPasswordRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'current_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentPassword = valueDes;
          break;
        case r'new_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPassword = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchAuthPasswordRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAuthPasswordRequestBuilder();
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
