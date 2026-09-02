//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_sync_pull200_response_changes_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_pull200_response.g.dart';

/// GetSyncPull200Response
///
/// Properties:
/// * [changes]
/// * [serverCursor]
/// * [hasMore]
@BuiltValue()
abstract class GetSyncPull200Response
    implements Built<GetSyncPull200Response, GetSyncPull200ResponseBuilder> {
  @BuiltValueField(wireName: r'changes')
  BuiltList<GetSyncPull200ResponseChangesInner> get changes;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  GetSyncPull200Response._();

  factory GetSyncPull200Response(
          [void updates(GetSyncPull200ResponseBuilder b)]) =
      _$GetSyncPull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncPull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncPull200Response> get serializer =>
      _$GetSyncPull200ResponseSerializer();
}

class _$GetSyncPull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncPull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncPull200Response,
    _$GetSyncPull200Response
  ];

  @override
  final String wireName = r'GetSyncPull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncPull200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(
          BuiltList, [FullType(GetSyncPull200ResponseChangesInner)]),
    );
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncPull200Response object, {
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
    required GetSyncPull200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(GetSyncPull200ResponseChangesInner)]),
          ) as BuiltList<GetSyncPull200ResponseChangesInner>;
          result.changes.replace(valueDes);
          break;
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncPull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncPull200ResponseBuilder();
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
