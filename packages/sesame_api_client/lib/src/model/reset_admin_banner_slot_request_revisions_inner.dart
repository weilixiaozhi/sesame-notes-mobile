//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'reset_admin_banner_slot_request_revisions_inner.g.dart';

/// ResetAdminBannerSlotRequestRevisionsInner
///
/// Properties:
/// * [id]
/// * [version]
@BuiltValue()
abstract class ResetAdminBannerSlotRequestRevisionsInner
    implements
        Built<ResetAdminBannerSlotRequestRevisionsInner,
            ResetAdminBannerSlotRequestRevisionsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'version')
  int get version;

  ResetAdminBannerSlotRequestRevisionsInner._();

  factory ResetAdminBannerSlotRequestRevisionsInner(
          [void updates(ResetAdminBannerSlotRequestRevisionsInnerBuilder b)]) =
      _$ResetAdminBannerSlotRequestRevisionsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResetAdminBannerSlotRequestRevisionsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResetAdminBannerSlotRequestRevisionsInner> get serializer =>
      _$ResetAdminBannerSlotRequestRevisionsInnerSerializer();
}

class _$ResetAdminBannerSlotRequestRevisionsInnerSerializer
    implements PrimitiveSerializer<ResetAdminBannerSlotRequestRevisionsInner> {
  @override
  final Iterable<Type> types = const [
    ResetAdminBannerSlotRequestRevisionsInner,
    _$ResetAdminBannerSlotRequestRevisionsInner
  ];

  @override
  final String wireName = r'ResetAdminBannerSlotRequestRevisionsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResetAdminBannerSlotRequestRevisionsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResetAdminBannerSlotRequestRevisionsInner object, {
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
    required ResetAdminBannerSlotRequestRevisionsInnerBuilder result,
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
  ResetAdminBannerSlotRequestRevisionsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResetAdminBannerSlotRequestRevisionsInnerBuilder();
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
