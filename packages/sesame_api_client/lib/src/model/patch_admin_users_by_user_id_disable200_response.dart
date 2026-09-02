//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_users_by_user_id_disable200_response.g.dart';

/// PatchAdminUsersByUserIdDisable200Response
///
/// Properties:
/// * [id]
/// * [phoneMasked]
/// * [isEnabled]
@BuiltValue()
abstract class PatchAdminUsersByUserIdDisable200Response
    implements
        Built<PatchAdminUsersByUserIdDisable200Response,
            PatchAdminUsersByUserIdDisable200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'phone_masked')
  String? get phoneMasked;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  PatchAdminUsersByUserIdDisable200Response._();

  factory PatchAdminUsersByUserIdDisable200Response(
          [void updates(PatchAdminUsersByUserIdDisable200ResponseBuilder b)]) =
      _$PatchAdminUsersByUserIdDisable200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAdminUsersByUserIdDisable200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminUsersByUserIdDisable200Response> get serializer =>
      _$PatchAdminUsersByUserIdDisable200ResponseSerializer();
}

class _$PatchAdminUsersByUserIdDisable200ResponseSerializer
    implements PrimitiveSerializer<PatchAdminUsersByUserIdDisable200Response> {
  @override
  final Iterable<Type> types = const [
    PatchAdminUsersByUserIdDisable200Response,
    _$PatchAdminUsersByUserIdDisable200Response
  ];

  @override
  final String wireName = r'PatchAdminUsersByUserIdDisable200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminUsersByUserIdDisable200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'phone_masked';
    yield object.phoneMasked == null
        ? null
        : serializers.serialize(
            object.phoneMasked,
            specifiedType: const FullType.nullable(String),
          );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchAdminUsersByUserIdDisable200Response object, {
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
    required PatchAdminUsersByUserIdDisable200ResponseBuilder result,
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
        case r'phone_masked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phoneMasked = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
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
  PatchAdminUsersByUserIdDisable200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminUsersByUserIdDisable200ResponseBuilder();
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
