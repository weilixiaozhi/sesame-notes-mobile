//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_admin_banner200_response.g.dart';

/// DeleteAdminBanner200Response
///
/// Properties:
/// * [ok]
@BuiltValue()
abstract class DeleteAdminBanner200Response
    implements
        Built<DeleteAdminBanner200Response,
            DeleteAdminBanner200ResponseBuilder> {
  @BuiltValueField(wireName: r'ok')
  bool get ok;

  DeleteAdminBanner200Response._();

  factory DeleteAdminBanner200Response(
          [void updates(DeleteAdminBanner200ResponseBuilder b)]) =
      _$DeleteAdminBanner200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAdminBanner200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAdminBanner200Response> get serializer =>
      _$DeleteAdminBanner200ResponseSerializer();
}

class _$DeleteAdminBanner200ResponseSerializer
    implements PrimitiveSerializer<DeleteAdminBanner200Response> {
  @override
  final Iterable<Type> types = const [
    DeleteAdminBanner200Response,
    _$DeleteAdminBanner200Response
  ];

  @override
  final String wireName = r'DeleteAdminBanner200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAdminBanner200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ok';
    yield serializers.serialize(
      object.ok,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteAdminBanner200Response object, {
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
    required DeleteAdminBanner200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ok':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.ok = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteAdminBanner200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAdminBanner200ResponseBuilder();
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
