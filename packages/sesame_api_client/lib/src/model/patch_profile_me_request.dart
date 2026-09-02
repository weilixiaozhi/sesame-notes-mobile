//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_profile_me_request.g.dart';

/// PatchProfileMeRequest
///
/// Properties:
/// * [displayName]
/// * [gender]
/// * [incomeIsRed]
/// * [themePrimaryColor]
/// * [appearance]
/// * [aiConfig]
/// * [primaryCurrency]
@BuiltValue()
abstract class PatchProfileMeRequest
    implements Built<PatchProfileMeRequest, PatchProfileMeRequestBuilder> {
  @BuiltValueField(wireName: r'display_name')
  String? get displayName;

  @BuiltValueField(wireName: r'gender')
  String? get gender;

  @BuiltValueField(wireName: r'income_is_red')
  bool? get incomeIsRed;

  @BuiltValueField(wireName: r'theme_primary_color')
  String? get themePrimaryColor;

  @BuiltValueField(wireName: r'appearance')
  BuiltMap<String, JsonObject?>? get appearance;

  @BuiltValueField(wireName: r'ai_config')
  BuiltMap<String, JsonObject?>? get aiConfig;

  @BuiltValueField(wireName: r'primary_currency')
  String? get primaryCurrency;

  PatchProfileMeRequest._();

  factory PatchProfileMeRequest(
      [void updates(PatchProfileMeRequestBuilder b)]) = _$PatchProfileMeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchProfileMeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchProfileMeRequest> get serializer =>
      _$PatchProfileMeRequestSerializer();
}

class _$PatchProfileMeRequestSerializer
    implements PrimitiveSerializer<PatchProfileMeRequest> {
  @override
  final Iterable<Type> types = const [
    PatchProfileMeRequest,
    _$PatchProfileMeRequest
  ];

  @override
  final String wireName = r'PatchProfileMeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchProfileMeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.displayName != null) {
      yield r'display_name';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.gender != null) {
      yield r'gender';
      yield serializers.serialize(
        object.gender,
        specifiedType: const FullType(String),
      );
    }
    if (object.incomeIsRed != null) {
      yield r'income_is_red';
      yield serializers.serialize(
        object.incomeIsRed,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.themePrimaryColor != null) {
      yield r'theme_primary_color';
      yield serializers.serialize(
        object.themePrimaryColor,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.appearance != null) {
      yield r'appearance';
      yield serializers.serialize(
        object.appearance,
        specifiedType: const FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.aiConfig != null) {
      yield r'ai_config';
      yield serializers.serialize(
        object.aiConfig,
        specifiedType: const FullType.nullable(
            BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.primaryCurrency != null) {
      yield r'primary_currency';
      yield serializers.serialize(
        object.primaryCurrency,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchProfileMeRequest object, {
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
    required PatchProfileMeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'gender':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.gender = valueDes;
          break;
        case r'income_is_red':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.incomeIsRed = valueDes;
          break;
        case r'theme_primary_color':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.themePrimaryColor = valueDes;
          break;
        case r'appearance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.appearance.replace(valueDes);
          break;
        case r'ai_config':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.aiConfig.replace(valueDes);
          break;
        case r'primary_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryCurrency = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchProfileMeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchProfileMeRequestBuilder();
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
