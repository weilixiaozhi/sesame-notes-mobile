//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_accounts_by_admin_id_request.g.dart';

/// PatchAdminAccountsByAdminIdRequest
///
/// Properties:
/// * [version]
/// * [displayName]
/// * [email]
/// * [phone]
/// * [groupId]
/// * [isEnabled]
/// * [reason]
@BuiltValue()
abstract class PatchAdminAccountsByAdminIdRequest
    implements
        Built<PatchAdminAccountsByAdminIdRequest,
            PatchAdminAccountsByAdminIdRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'group_id')
  String? get groupId;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  PatchAdminAccountsByAdminIdRequest._();

  factory PatchAdminAccountsByAdminIdRequest(
          [void updates(PatchAdminAccountsByAdminIdRequestBuilder b)]) =
      _$PatchAdminAccountsByAdminIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAdminAccountsByAdminIdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminAccountsByAdminIdRequest> get serializer =>
      _$PatchAdminAccountsByAdminIdRequestSerializer();
}

class _$PatchAdminAccountsByAdminIdRequestSerializer
    implements PrimitiveSerializer<PatchAdminAccountsByAdminIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAdminAccountsByAdminIdRequest,
    _$PatchAdminAccountsByAdminIdRequest
  ];

  @override
  final String wireName = r'PatchAdminAccountsByAdminIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminAccountsByAdminIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.displayName != null) {
      yield r'display_name';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.phone != null) {
      yield r'phone';
      yield serializers.serialize(
        object.phone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.groupId != null) {
      yield r'group_id';
      yield serializers.serialize(
        object.groupId,
        specifiedType: const FullType(String),
      );
    }
    if (object.isEnabled != null) {
      yield r'is_enabled';
      yield serializers.serialize(
        object.isEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchAdminAccountsByAdminIdRequest object, {
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
    required PatchAdminAccountsByAdminIdRequestBuilder result,
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
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'group_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.groupId = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isEnabled = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  PatchAdminAccountsByAdminIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminAccountsByAdminIdRequestBuilder();
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
