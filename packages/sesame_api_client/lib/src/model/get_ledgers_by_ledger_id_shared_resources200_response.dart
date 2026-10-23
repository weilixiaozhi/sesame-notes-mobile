//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_shared_resources200_response.g.dart';

/// GetLedgersByLedgerIdSharedResources200Response
///
/// Properties:
/// * [ownerUserId]
/// * [categories]
@BuiltValue()
abstract class GetLedgersByLedgerIdSharedResources200Response
    implements
        Built<GetLedgersByLedgerIdSharedResources200Response,
            GetLedgersByLedgerIdSharedResources200ResponseBuilder> {
  @BuiltValueField(wireName: r'owner_user_id')
  String get ownerUserId;

  @BuiltValueField(wireName: r'categories')
  BuiltList<Category> get categories;

  GetLedgersByLedgerIdSharedResources200Response._();

  factory GetLedgersByLedgerIdSharedResources200Response(
          [void updates(
              GetLedgersByLedgerIdSharedResources200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdSharedResources200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdSharedResources200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdSharedResources200Response>
      get serializer =>
          _$GetLedgersByLedgerIdSharedResources200ResponseSerializer();
}

class _$GetLedgersByLedgerIdSharedResources200ResponseSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdSharedResources200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdSharedResources200Response,
    _$GetLedgersByLedgerIdSharedResources200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdSharedResources200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdSharedResources200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'owner_user_id';
    yield serializers.serialize(
      object.ownerUserId,
      specifiedType: const FullType(String),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdSharedResources200Response object, {
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
    required GetLedgersByLedgerIdSharedResources200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'owner_user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ownerUserId = valueDes;
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categories.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdSharedResources200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdSharedResources200ResponseBuilder();
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
