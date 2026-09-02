//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_imports400_response_details_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_imports400_response.g.dart';

/// PostLedgersByLedgerIdImports400Response
///
/// Properties:
/// * [code]
/// * [message]
/// * [requestId]
/// * [details]
@BuiltValue()
abstract class PostLedgersByLedgerIdImports400Response
    implements
        Built<PostLedgersByLedgerIdImports400Response,
            PostLedgersByLedgerIdImports400ResponseBuilder> {
  @BuiltValueField(wireName: r'code')
  PostLedgersByLedgerIdImports400ResponseCodeEnum get code;
  // enum codeEnum {  IMPORT_VALIDATION_FAILED,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'request_id')
  String get requestId;

  @BuiltValueField(wireName: r'details')
  BuiltList<PostLedgersByLedgerIdImports400ResponseDetailsInner> get details;

  PostLedgersByLedgerIdImports400Response._();

  factory PostLedgersByLedgerIdImports400Response(
          [void updates(PostLedgersByLedgerIdImports400ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdImports400Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdImports400ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdImports400Response> get serializer =>
      _$PostLedgersByLedgerIdImports400ResponseSerializer();
}

class _$PostLedgersByLedgerIdImports400ResponseSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdImports400Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdImports400Response,
    _$PostLedgersByLedgerIdImports400Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdImports400Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdImports400Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType:
          const FullType(PostLedgersByLedgerIdImports400ResponseCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'request_id';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
    yield r'details';
    yield serializers.serialize(
      object.details,
      specifiedType: const FullType(BuiltList,
          [FullType(PostLedgersByLedgerIdImports400ResponseDetailsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdImports400Response object, {
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
    required PostLedgersByLedgerIdImports400ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostLedgersByLedgerIdImports400ResponseCodeEnum),
          ) as PostLedgersByLedgerIdImports400ResponseCodeEnum;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(PostLedgersByLedgerIdImports400ResponseDetailsInner)
            ]),
          ) as BuiltList<PostLedgersByLedgerIdImports400ResponseDetailsInner>;
          result.details.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdImports400Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdImports400ResponseBuilder();
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

class PostLedgersByLedgerIdImports400ResponseCodeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'IMPORT_VALIDATION_FAILED')
  static const PostLedgersByLedgerIdImports400ResponseCodeEnum
      IMPORT_VALIDATION_FAILED =
      _$postLedgersByLedgerIdImports400ResponseCodeEnum_IMPORT_VALIDATION_FAILED;

  static Serializer<PostLedgersByLedgerIdImports400ResponseCodeEnum>
      get serializer =>
          _$postLedgersByLedgerIdImports400ResponseCodeEnumSerializer;

  const PostLedgersByLedgerIdImports400ResponseCodeEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdImports400ResponseCodeEnum> get values =>
      _$postLedgersByLedgerIdImports400ResponseCodeEnumValues;
  static PostLedgersByLedgerIdImports400ResponseCodeEnum valueOf(String name) =>
      _$postLedgersByLedgerIdImports400ResponseCodeEnumValueOf(name);
}
