//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_groups200_response_items_inner.g.dart';

/// GetAdminGroups200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [isDefault]
/// * [name]
/// * [description]
/// * [sort]
/// * [isEnabled]
/// * [permissions]
/// * [pageIds]
/// * [version]
/// * [memberCount]
/// * [createdBy]
/// * [updatedBy]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class GetAdminGroups200ResponseItemsInner
    implements
        Built<GetAdminGroups200ResponseItemsInner,
            GetAdminGroups200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'is_default')
  bool get isDefault;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'description')
  String get description;

  @BuiltValueField(wireName: r'sort')
  int get sort;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'permissions')
  BuiltList<String> get permissions;

  @BuiltValueField(wireName: r'page_ids')
  BuiltList<String> get pageIds;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'member_count')
  int get memberCount;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  GetAdminGroups200ResponseItemsInner._();

  factory GetAdminGroups200ResponseItemsInner(
          [void updates(GetAdminGroups200ResponseItemsInnerBuilder b)]) =
      _$GetAdminGroups200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminGroups200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminGroups200ResponseItemsInner> get serializer =>
      _$GetAdminGroups200ResponseItemsInnerSerializer();
}

class _$GetAdminGroups200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<GetAdminGroups200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminGroups200ResponseItemsInner,
    _$GetAdminGroups200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminGroups200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminGroups200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'is_default';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'sort';
    yield serializers.serialize(
      object.sort,
      specifiedType: const FullType(int),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'page_ids';
    yield serializers.serialize(
      object.pageIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'member_count';
    yield serializers.serialize(
      object.memberCount,
      specifiedType: const FullType(int),
    );
    yield r'created_by';
    yield object.createdBy == null
        ? null
        : serializers.serialize(
            object.createdBy,
            specifiedType: const FullType.nullable(String),
          );
    yield r'updated_by';
    yield object.updatedBy == null
        ? null
        : serializers.serialize(
            object.updatedBy,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminGroups200ResponseItemsInner object, {
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
    required GetAdminGroups200ResponseItemsInnerBuilder result,
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
        case r'is_default':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'sort':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sort = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.permissions.replace(valueDes);
          break;
        case r'page_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.pageIds.replace(valueDes);
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'member_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCount = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'updated_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminGroups200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminGroups200ResponseItemsInnerBuilder();
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
