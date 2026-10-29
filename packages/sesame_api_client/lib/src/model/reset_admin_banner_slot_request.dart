//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/reset_admin_banner_slot_request_revisions_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reset_admin_banner_slot_request.g.dart';

/// ResetAdminBannerSlotRequest
///
/// Properties:
/// * [revisions]
@BuiltValue()
abstract class ResetAdminBannerSlotRequest
    implements
        Built<ResetAdminBannerSlotRequest, ResetAdminBannerSlotRequestBuilder> {
  @BuiltValueField(wireName: r'revisions')
  BuiltSet<ResetAdminBannerSlotRequestRevisionsInner> get revisions;

  ResetAdminBannerSlotRequest._();

  factory ResetAdminBannerSlotRequest(
          [void updates(ResetAdminBannerSlotRequestBuilder b)]) =
      _$ResetAdminBannerSlotRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResetAdminBannerSlotRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResetAdminBannerSlotRequest> get serializer =>
      _$ResetAdminBannerSlotRequestSerializer();
}

class _$ResetAdminBannerSlotRequestSerializer
    implements PrimitiveSerializer<ResetAdminBannerSlotRequest> {
  @override
  final Iterable<Type> types = const [
    ResetAdminBannerSlotRequest,
    _$ResetAdminBannerSlotRequest
  ];

  @override
  final String wireName = r'ResetAdminBannerSlotRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResetAdminBannerSlotRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'revisions';
    yield serializers.serialize(
      object.revisions,
      specifiedType: const FullType(
          BuiltSet, [FullType(ResetAdminBannerSlotRequestRevisionsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResetAdminBannerSlotRequest object, {
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
    required ResetAdminBannerSlotRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'revisions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet,
                [FullType(ResetAdminBannerSlotRequestRevisionsInner)]),
          ) as BuiltSet<ResetAdminBannerSlotRequestRevisionsInner>;
          result.revisions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ResetAdminBannerSlotRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResetAdminBannerSlotRequestBuilder();
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
