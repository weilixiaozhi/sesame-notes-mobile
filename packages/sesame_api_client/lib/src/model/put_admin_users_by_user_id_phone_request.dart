//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_admin_users_by_user_id_phone_request.g.dart';

/// PutAdminUsersByUserIdPhoneRequest
///
/// Properties:
/// * [countryCode]
/// * [phone]
/// * [currentPhone]
/// * [reason]
@BuiltValue()
abstract class PutAdminUsersByUserIdPhoneRequest
    implements
        Built<PutAdminUsersByUserIdPhoneRequest,
            PutAdminUsersByUserIdPhoneRequestBuilder> {
  @BuiltValueField(wireName: r'country_code')
  String get countryCode;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'current_phone')
  String get currentPhone;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PutAdminUsersByUserIdPhoneRequest._();

  factory PutAdminUsersByUserIdPhoneRequest(
          [void updates(PutAdminUsersByUserIdPhoneRequestBuilder b)]) =
      _$PutAdminUsersByUserIdPhoneRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutAdminUsersByUserIdPhoneRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutAdminUsersByUserIdPhoneRequest> get serializer =>
      _$PutAdminUsersByUserIdPhoneRequestSerializer();
}

class _$PutAdminUsersByUserIdPhoneRequestSerializer
    implements PrimitiveSerializer<PutAdminUsersByUserIdPhoneRequest> {
  @override
  final Iterable<Type> types = const [
    PutAdminUsersByUserIdPhoneRequest,
    _$PutAdminUsersByUserIdPhoneRequest
  ];

  @override
  final String wireName = r'PutAdminUsersByUserIdPhoneRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutAdminUsersByUserIdPhoneRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'country_code';
    yield serializers.serialize(
      object.countryCode,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'current_phone';
    yield serializers.serialize(
      object.currentPhone,
      specifiedType: const FullType(String),
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
    PutAdminUsersByUserIdPhoneRequest object, {
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
    required PutAdminUsersByUserIdPhoneRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'country_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.countryCode = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'current_phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currentPhone = valueDes;
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
  PutAdminUsersByUserIdPhoneRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutAdminUsersByUserIdPhoneRequestBuilder();
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
