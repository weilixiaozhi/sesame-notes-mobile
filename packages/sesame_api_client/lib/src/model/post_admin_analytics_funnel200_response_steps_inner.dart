//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_analytics_funnel200_response_steps_inner.g.dart';

/// PostAdminAnalyticsFunnel200ResponseStepsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [users]
/// * [conversionRate]
/// * [dropOff]
@BuiltValue()
abstract class PostAdminAnalyticsFunnel200ResponseStepsInner
    implements
        Built<PostAdminAnalyticsFunnel200ResponseStepsInner,
            PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'users')
  int get users;

  @BuiltValueField(wireName: r'conversion_rate')
  num? get conversionRate;

  @BuiltValueField(wireName: r'drop_off')
  int get dropOff;

  PostAdminAnalyticsFunnel200ResponseStepsInner._();

  factory PostAdminAnalyticsFunnel200ResponseStepsInner(
          [void updates(
              PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder b)]) =
      _$PostAdminAnalyticsFunnel200ResponseStepsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAnalyticsFunnel200ResponseStepsInner>
      get serializer =>
          _$PostAdminAnalyticsFunnel200ResponseStepsInnerSerializer();
}

class _$PostAdminAnalyticsFunnel200ResponseStepsInnerSerializer
    implements
        PrimitiveSerializer<PostAdminAnalyticsFunnel200ResponseStepsInner> {
  @override
  final Iterable<Type> types = const [
    PostAdminAnalyticsFunnel200ResponseStepsInner,
    _$PostAdminAnalyticsFunnel200ResponseStepsInner
  ];

  @override
  final String wireName = r'PostAdminAnalyticsFunnel200ResponseStepsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseStepsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(int),
    );
    yield r'conversion_rate';
    yield object.conversionRate == null
        ? null
        : serializers.serialize(
            object.conversionRate,
            specifiedType: const FullType.nullable(num),
          );
    yield r'drop_off';
    yield serializers.serialize(
      object.dropOff,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAnalyticsFunnel200ResponseStepsInner object, {
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
    required PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.users = valueDes;
          break;
        case r'conversion_rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.conversionRate = valueDes;
          break;
        case r'drop_off':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dropOff = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAnalyticsFunnel200ResponseStepsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAnalyticsFunnel200ResponseStepsInnerBuilder();
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
