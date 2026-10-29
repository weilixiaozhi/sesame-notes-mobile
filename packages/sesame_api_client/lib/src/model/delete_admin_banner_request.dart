//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_admin_banner_request.g.dart';

/// DeleteAdminBannerRequest
///
/// Properties:
/// * [version]
@BuiltValue()
abstract class DeleteAdminBannerRequest
    implements
        Built<DeleteAdminBannerRequest, DeleteAdminBannerRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  DeleteAdminBannerRequest._();

  factory DeleteAdminBannerRequest(
          [void updates(DeleteAdminBannerRequestBuilder b)]) =
      _$DeleteAdminBannerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAdminBannerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAdminBannerRequest> get serializer =>
      _$DeleteAdminBannerRequestSerializer();
}

class _$DeleteAdminBannerRequestSerializer
    implements PrimitiveSerializer<DeleteAdminBannerRequest> {
  @override
  final Iterable<Type> types = const [
    DeleteAdminBannerRequest,
    _$DeleteAdminBannerRequest
  ];

  @override
  final String wireName = r'DeleteAdminBannerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAdminBannerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteAdminBannerRequest object, {
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
    required DeleteAdminBannerRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteAdminBannerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAdminBannerRequestBuilder();
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
