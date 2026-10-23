//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_remove_request.g.dart';

/// PostLedgersByLedgerIdCategoriesRemoveRequest
///
/// Properties:
/// * [categoryIds]
/// * [mode]
/// * [targetCategoryId]
/// * [expectedTargetUpdatedAt]
/// * [previewToken]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesRemoveRequest
    implements
        Built<PostLedgersByLedgerIdCategoriesRemoveRequest,
            PostLedgersByLedgerIdCategoriesRemoveRequestBuilder> {
  @BuiltValueField(wireName: r'category_ids')
  BuiltSet<String> get categoryIds;

  @BuiltValueField(wireName: r'mode')
  PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum get mode;
  // enum modeEnum {  migrate,  delete,  promote,  };

  @BuiltValueField(wireName: r'target_category_id')
  String? get targetCategoryId;

  @BuiltValueField(wireName: r'expected_target_updated_at')
  DateTime? get expectedTargetUpdatedAt;

  @BuiltValueField(wireName: r'preview_token')
  String get previewToken;

  PostLedgersByLedgerIdCategoriesRemoveRequest._();

  factory PostLedgersByLedgerIdCategoriesRemoveRequest(
          [void updates(
              PostLedgersByLedgerIdCategoriesRemoveRequestBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesRemoveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesRemoveRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesRemoveRequest>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesRemoveRequestSerializer();
}

class _$PostLedgersByLedgerIdCategoriesRemoveRequestSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesRemoveRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesRemoveRequest,
    _$PostLedgersByLedgerIdCategoriesRemoveRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdCategoriesRemoveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemoveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category_ids';
    yield serializers.serialize(
      object.categoryIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType:
          const FullType(PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum),
    );
    if (object.targetCategoryId != null) {
      yield r'target_category_id';
      yield serializers.serialize(
        object.targetCategoryId,
        specifiedType: const FullType(String),
      );
    }
    if (object.expectedTargetUpdatedAt != null) {
      yield r'expected_target_updated_at';
      yield serializers.serialize(
        object.expectedTargetUpdatedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    yield r'preview_token';
    yield serializers.serialize(
      object.previewToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemoveRequest object, {
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
    required PostLedgersByLedgerIdCategoriesRemoveRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.categoryIds.replace(valueDes);
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum),
          ) as PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum;
          result.mode = valueDes;
          break;
        case r'target_category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetCategoryId = valueDes;
          break;
        case r'expected_target_updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expectedTargetUpdatedAt = valueDes;
          break;
        case r'preview_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesRemoveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdCategoriesRemoveRequestBuilder();
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

class PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'migrate')
  static const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum migrate =
      _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_migrate;
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum delete =
      _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_delete;
  @BuiltValueEnumConst(wireName: r'promote')
  static const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum promote =
      _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnum_promote;

  static Serializer<PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>
      get serializer =>
          _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumSerializer;

  const PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum>
      get values =>
          _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumValues;
  static PostLedgersByLedgerIdCategoriesRemoveRequestModeEnum valueOf(
          String name) =>
      _$postLedgersByLedgerIdCategoriesRemoveRequestModeEnumValueOf(name);
}
