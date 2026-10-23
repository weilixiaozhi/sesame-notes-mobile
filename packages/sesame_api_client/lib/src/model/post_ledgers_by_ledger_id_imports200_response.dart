//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_imports200_response.g.dart';

/// PostLedgersByLedgerIdImports200Response
///
/// Properties:
/// * [importedCategories]
/// * [importedTransactions]
@BuiltValue()
abstract class PostLedgersByLedgerIdImports200Response
    implements
        Built<PostLedgersByLedgerIdImports200Response,
            PostLedgersByLedgerIdImports200ResponseBuilder> {
  @BuiltValueField(wireName: r'imported_categories')
  int get importedCategories;

  @BuiltValueField(wireName: r'imported_transactions')
  int get importedTransactions;

  PostLedgersByLedgerIdImports200Response._();

  factory PostLedgersByLedgerIdImports200Response(
          [void updates(PostLedgersByLedgerIdImports200ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdImports200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdImports200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdImports200Response> get serializer =>
      _$PostLedgersByLedgerIdImports200ResponseSerializer();
}

class _$PostLedgersByLedgerIdImports200ResponseSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdImports200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdImports200Response,
    _$PostLedgersByLedgerIdImports200Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdImports200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdImports200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'imported_categories';
    yield serializers.serialize(
      object.importedCategories,
      specifiedType: const FullType(int),
    );
    yield r'imported_transactions';
    yield serializers.serialize(
      object.importedTransactions,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdImports200Response object, {
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
    required PostLedgersByLedgerIdImports200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'imported_categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.importedCategories = valueDes;
          break;
        case r'imported_transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.importedTransactions = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdImports200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdImports200ResponseBuilder();
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
