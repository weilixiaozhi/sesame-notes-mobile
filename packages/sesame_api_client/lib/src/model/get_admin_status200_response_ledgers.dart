//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_status200_response_ledgers.g.dart';

/// GetAdminStatus200ResponseLedgers
///
/// Properties:
/// * [total]
@BuiltValue()
abstract class GetAdminStatus200ResponseLedgers
    implements
        Built<GetAdminStatus200ResponseLedgers,
            GetAdminStatus200ResponseLedgersBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  GetAdminStatus200ResponseLedgers._();

  factory GetAdminStatus200ResponseLedgers(
          [void updates(GetAdminStatus200ResponseLedgersBuilder b)]) =
      _$GetAdminStatus200ResponseLedgers;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminStatus200ResponseLedgersBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminStatus200ResponseLedgers> get serializer =>
      _$GetAdminStatus200ResponseLedgersSerializer();
}

class _$GetAdminStatus200ResponseLedgersSerializer
    implements PrimitiveSerializer<GetAdminStatus200ResponseLedgers> {
  @override
  final Iterable<Type> types = const [
    GetAdminStatus200ResponseLedgers,
    _$GetAdminStatus200ResponseLedgers
  ];

  @override
  final String wireName = r'GetAdminStatus200ResponseLedgers';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminStatus200ResponseLedgers object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminStatus200ResponseLedgers object, {
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
    required GetAdminStatus200ResponseLedgersBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminStatus200ResponseLedgers deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminStatus200ResponseLedgersBuilder();
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
