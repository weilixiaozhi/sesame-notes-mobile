import 'package:built_value/serializer.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;

/// 目录版本显式校验，分类数值枚举保持整数传输，开放JSON载荷保持原样。
final apiSerializers = _buildApiSerializers();

/// 在SDK注入点组合目录版本与分类枚举边界，不改写开放业务载荷。
Serializers _buildApiSerializers() {
  try {
    return (api.standardSerializers.toBuilder()
          ..add(_FitnessCatalogSerializer())
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api.CategoryLevelEnum.serializer,
            ),
          )
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api.CategoryConflictLocalPayloadLevelEnum.serializer,
            ),
          )
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api
                  .PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum
                  .serializer,
            ),
          )
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api.PostLedgersByLedgerIdCategoriesRequestLevelEnum.serializer,
            ),
          )
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api
                  .PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
                  .serializer,
            ),
          )
          ..add(
            _IntegerEnumSerializer.categoryLevel(
              api
                  .PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
                  .serializer,
            ),
          ))
        .build();
  } catch (error, stack) {
    Error.throwWithStackTrace(
      StateError('API 数字枚举序列化器初始化失败：${error.runtimeType}'),
      stack,
    );
  }
}

/// 目录DTO在生产边界只接受当前数字版本，其余字段交给生成序列化器处理。
class _FitnessCatalogSerializer
    implements PrimitiveSerializer<api.GetFitnessCatalog200Response> {
  /// 复用生成器的字段解析，不维护第二套目录字段映射。
  _FitnessCatalogSerializer()
    : _delegate =
          api.GetFitnessCatalog200Response.serializer
              as PrimitiveSerializer<api.GetFitnessCatalog200Response>;

  final PrimitiveSerializer<api.GetFitnessCatalog200Response> _delegate;

  @override
  Iterable<Type> get types => _delegate.types;

  @override
  String get wireName => _delegate.wireName;

  /// 发送前核对DTO版本，禁止把未支持的目录结构标记成正常载荷。
  @override
  Object serialize(
    Serializers serializers,
    api.GetFitnessCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    try {
      if (object.schemaVersion != 1) {
        throw const FormatException('健身目录 schema_version 必须为 1');
      }
      return _delegate.serialize(
        serializers,
        object,
        specifiedType: specifiedType,
      );
    } catch (error, stack) {
      Error.throwWithStackTrace(
        error is FormatException ? error : const FormatException('健身目录响应格式无效'),
        stack,
      );
    }
  }

  /// JSON 插件提供字段/值序列；只检查此 DTO 顶层版本，不改写开放业务内容。
  @override
  api.GetFitnessCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    try {
      final fields = (serialized as Iterable<Object?>).toList(growable: false);
      var versions = 0;
      var versionIndex = -1;
      Object? version;
      for (var index = 0; index + 1 < fields.length; index += 2) {
        if (fields[index] == 'schema_version') {
          versions++;
          versionIndex = index + 1;
          version = fields[index + 1];
        }
      }
      if (versions != 1 || version is! num || version != 1) {
        throw const FormatException('健身目录 schema_version 必须为 1');
      }
      // JSON数字1.0与1满足同一字面值约束，仅此DTO版本槽位规范为生成模型所需整数。
      fields[versionIndex] = 1;
      return _delegate.deserialize(
        serializers,
        fields,
        specifiedType: specifiedType,
      );
    } catch (error, stack) {
      Error.throwWithStackTrace(
        error is FormatException ? error : const FormatException('健身目录响应格式无效'),
        stack,
      );
    }
  }
}

/// 委托明确 DTO 的生成枚举验证值域，只转换整数和枚举 wire name。
class _IntegerEnumSerializer<T> implements PrimitiveSerializer<T> {
  /// 已注册的六个分类层级枚举均由生成器提供 primitive serializer。
  _IntegerEnumSerializer.categoryLevel(Serializer<T> delegate)
    : this(delegate, invalidValueMessage: '分类层级必须为 1 或 2');

  /// 调用方明确提供 DTO 的合法值域说明，错误文案不包含服务端正文。
  _IntegerEnumSerializer(
    Serializer<T> delegate, {
    required this.invalidValueMessage,
  }) : _delegate = delegate as PrimitiveSerializer<T>;

  final String invalidValueMessage;

  final PrimitiveSerializer<T> _delegate;

  @override
  Iterable<Type> get types => _delegate.types;

  @override
  String get wireName => _delegate.wireName;

  /// JSON 请求与同步投影均保留正式契约的整数类型。
  @override
  Object serialize(
    Serializers serializers,
    T object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    try {
      final wire = _delegate.serialize(
        serializers,
        object,
        specifiedType: specifiedType,
      );
      return int.parse(wire as String);
    } catch (error, stack) {
      Error.throwWithStackTrace(FormatException(invalidValueMessage), stack);
    }
  }

  /// 只对当前 DTO 枚举接收数字，其他 DTO 中的 level 和 JsonObject 完全不变。
  @override
  T deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    try {
      return _delegate.deserialize(
        serializers,
        serialized is int ? serialized.toString() : serialized,
        specifiedType: specifiedType,
      );
    } catch (error, stack) {
      Error.throwWithStackTrace(FormatException(invalidValueMessage), stack);
    }
  }
}
