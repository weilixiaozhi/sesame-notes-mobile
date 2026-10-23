//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_invites_request.g.dart';

/// PostLedgersByLedgerIdInvitesRequest
///
/// Properties:
/// * [expiresInHours]
@BuiltValue()
abstract class PostLedgersByLedgerIdInvitesRequest
    implements
        Built<PostLedgersByLedgerIdInvitesRequest,
            PostLedgersByLedgerIdInvitesRequestBuilder> {
  @BuiltValueField(wireName: r'expires_in_hours')
  int? get expiresInHours;

  PostLedgersByLedgerIdInvitesRequest._();

  factory PostLedgersByLedgerIdInvitesRequest(
          [void updates(PostLedgersByLedgerIdInvitesRequestBuilder b)]) =
      _$PostLedgersByLedgerIdInvitesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdInvitesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdInvitesRequest> get serializer =>
      _$PostLedgersByLedgerIdInvitesRequestSerializer();
}

class _$PostLedgersByLedgerIdInvitesRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdInvitesRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdInvitesRequest,
    _$PostLedgersByLedgerIdInvitesRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdInvitesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdInvitesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.expiresInHours != null) {
      yield r'expires_in_hours';
      yield serializers.serialize(
        object.expiresInHours,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdInvitesRequest object, {
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
    required PostLedgersByLedgerIdInvitesRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expires_in_hours':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.expiresInHours = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdInvitesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdInvitesRequestBuilder();
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
