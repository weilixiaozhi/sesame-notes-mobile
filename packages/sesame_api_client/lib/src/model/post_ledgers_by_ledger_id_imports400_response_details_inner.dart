//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_imports400_response_details_inner.g.dart';

/// PostLedgersByLedgerIdImports400ResponseDetailsInner
///
/// Properties:
/// * [entity]
/// * [index]
/// * [reason]
@BuiltValue()
abstract class PostLedgersByLedgerIdImports400ResponseDetailsInner
    implements
        Built<PostLedgersByLedgerIdImports400ResponseDetailsInner,
            PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder> {
  @BuiltValueField(wireName: r'entity')
  PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum get entity;
  // enum entityEnum {  category,  transaction,  };

  @BuiltValueField(wireName: r'index')
  int get index;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PostLedgersByLedgerIdImports400ResponseDetailsInner._();

  factory PostLedgersByLedgerIdImports400ResponseDetailsInner(
          [void updates(
              PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder b)]) =
      _$PostLedgersByLedgerIdImports400ResponseDetailsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdImports400ResponseDetailsInner>
      get serializer =>
          _$PostLedgersByLedgerIdImports400ResponseDetailsInnerSerializer();
}

class _$PostLedgersByLedgerIdImports400ResponseDetailsInnerSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdImports400ResponseDetailsInner> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdImports400ResponseDetailsInner,
    _$PostLedgersByLedgerIdImports400ResponseDetailsInner
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdImports400ResponseDetailsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdImports400ResponseDetailsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entity';
    yield serializers.serialize(
      object.entity,
      specifiedType: const FullType(
          PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum),
    );
    yield r'index';
    yield serializers.serialize(
      object.index,
      specifiedType: const FullType(int),
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
    PostLedgersByLedgerIdImports400ResponseDetailsInner object, {
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
    required PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum),
          ) as PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum;
          result.entity = valueDes;
          break;
        case r'index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.index = valueDes;
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
  PostLedgersByLedgerIdImports400ResponseDetailsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdImports400ResponseDetailsInnerBuilder();
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

class PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'category')
  static const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
      category =
      _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_category;
  @BuiltValueEnumConst(wireName: r'transaction')
  static const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum
      transaction =
      _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum_transaction;

  static Serializer<
          PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>
      get serializer =>
          _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumSerializer;

  const PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum._(
      String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum>
      get values =>
          _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumValues;
  static PostLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnum valueOf(
          String name) =>
      _$postLedgersByLedgerIdImports400ResponseDetailsInnerEntityEnumValueOf(
          name);
}
