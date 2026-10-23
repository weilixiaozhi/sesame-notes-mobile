//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_admin_groups_by_group_id_permissions_request.g.dart';

/// PutAdminGroupsByGroupIdPermissionsRequest
///
/// Properties:
/// * [version]
/// * [permissions]
/// * [pageIds]
/// * [reason]
@BuiltValue()
abstract class PutAdminGroupsByGroupIdPermissionsRequest
    implements
        Built<PutAdminGroupsByGroupIdPermissionsRequest,
            PutAdminGroupsByGroupIdPermissionsRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'permissions')
  BuiltSet<String> get permissions;

  @BuiltValueField(wireName: r'page_ids')
  BuiltSet<String> get pageIds;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PutAdminGroupsByGroupIdPermissionsRequest._();

  factory PutAdminGroupsByGroupIdPermissionsRequest(
          [void updates(PutAdminGroupsByGroupIdPermissionsRequestBuilder b)]) =
      _$PutAdminGroupsByGroupIdPermissionsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutAdminGroupsByGroupIdPermissionsRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutAdminGroupsByGroupIdPermissionsRequest> get serializer =>
      _$PutAdminGroupsByGroupIdPermissionsRequestSerializer();
}

class _$PutAdminGroupsByGroupIdPermissionsRequestSerializer
    implements PrimitiveSerializer<PutAdminGroupsByGroupIdPermissionsRequest> {
  @override
  final Iterable<Type> types = const [
    PutAdminGroupsByGroupIdPermissionsRequest,
    _$PutAdminGroupsByGroupIdPermissionsRequest
  ];

  @override
  final String wireName = r'PutAdminGroupsByGroupIdPermissionsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutAdminGroupsByGroupIdPermissionsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'page_ids';
    yield serializers.serialize(
      object.pageIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
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
    PutAdminGroupsByGroupIdPermissionsRequest object, {
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
    required PutAdminGroupsByGroupIdPermissionsRequestBuilder result,
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
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.permissions.replace(valueDes);
          break;
        case r'page_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.pageIds.replace(valueDes);
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
  PutAdminGroupsByGroupIdPermissionsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutAdminGroupsByGroupIdPermissionsRequestBuilder();
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
