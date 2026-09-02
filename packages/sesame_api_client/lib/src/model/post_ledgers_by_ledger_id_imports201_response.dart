//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_imports201_response.g.dart';

/// PostLedgersByLedgerIdImports201Response
///
/// Properties:
/// * [importedCategories]
/// * [importedTransactions]
@BuiltValue()
abstract class PostLedgersByLedgerIdImports201Response
    implements
        Built<PostLedgersByLedgerIdImports201Response,
            PostLedgersByLedgerIdImports201ResponseBuilder> {
  @BuiltValueField(wireName: r'imported_categories')
  int get importedCategories;

  @BuiltValueField(wireName: r'imported_transactions')
  int get importedTransactions;

  PostLedgersByLedgerIdImports201Response._();

  factory PostLedgersByLedgerIdImports201Response(
          [void updates(PostLedgersByLedgerIdImports201ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdImports201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdImports201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdImports201Response> get serializer =>
      _$PostLedgersByLedgerIdImports201ResponseSerializer();
}

class _$PostLedgersByLedgerIdImports201ResponseSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdImports201Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdImports201Response,
    _$PostLedgersByLedgerIdImports201Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdImports201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdImports201Response object, {
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
    PostLedgersByLedgerIdImports201Response object, {
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
    required PostLedgersByLedgerIdImports201ResponseBuilder result,
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
  PostLedgersByLedgerIdImports201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdImports201ResponseBuilder();
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
