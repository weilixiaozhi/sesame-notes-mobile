import 'package:built_value/json_object.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';

/// DTO 数字枚举适配不改变业务开放载荷，也不修改其他数字协议字段。
void main() {
  test('健身目录数字版本精确适配，响应与再序列化保持整数且拒绝未知版本', () {
    final raw = {
      'schema_version': 1,
      'content_version': 7,
      'exercises': <Object>[],
    };
    final catalog = apiSerializers.deserializeWith(
      GetFitnessCatalog200Response.serializer,
      raw,
    )!;
    expect(catalog.schemaVersion, 1);
    expect(
      apiSerializers.serializeWith(
        GetFitnessCatalog200Response.serializer,
        catalog,
      ),
      raw,
    );
    final numericVersion = {...raw, 'schema_version': 1.0};
    final numericCatalog = apiSerializers.deserializeWith(
      GetFitnessCatalog200Response.serializer,
      numericVersion,
    )!;
    expect(numericCatalog.schemaVersion, 1);
    expect(
      apiSerializers.serializeWith(
        GetFitnessCatalog200Response.serializer,
        numericCatalog,
      ),
      raw,
    );
    expect(numericVersion['schema_version'], isA<double>());
    for (final invalid in [0, 2, -1, 1.5, true, null, '1', 'invalid']) {
      expect(
        () => apiSerializers.deserializeWith(
          GetFitnessCatalog200Response.serializer,
          {...raw, 'schema_version': invalid},
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            '明确版本范围',
            '健身目录 schema_version 必须为 1',
          ),
        ),
      );
    }
    final missingVersion = {...raw}..remove('schema_version');
    expect(
      () => apiSerializers.deserializeWith(
        GetFitnessCatalog200Response.serializer,
        missingVersion,
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => apiSerializers.serializeWith(
        GetFitnessCatalog200Response.serializer,
        catalog.rebuild((builder) => builder.schemaVersion = 2),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      apiSerializers.serialize(
        TransactionAaModeEnum.n1,
        specifiedType: const FullType(TransactionAaModeEnum),
      ),
      '1',
    );
  });

  test('六种明确分类枚举均保持整数往返', () {
    for (final type in [
      CategoryLevelEnum,
      CategoryConflictLocalPayloadLevelEnum,
      PatchLedgersByLedgerIdCategoriesByCategoryIdRequestLevelEnum,
      PostLedgersByLedgerIdCategoriesRequestLevelEnum,
      PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum,
      PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum,
    ]) {
      for (final level in [1, 2]) {
        final specified = FullType(type);
        final value = apiSerializers.deserialize(
          level,
          specifiedType: specified,
        );
        expect(
          apiSerializers.serialize(value, specifiedType: specified),
          level,
        );
      }
      for (final invalid in [0, 3, -1, 1.5, true, 'invalid']) {
        expect(
          () => apiSerializers.deserialize(
            invalid,
            specifiedType: FullType(type),
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              '明确值域错误',
              '分类层级必须为 1 或 2',
            ),
          ),
          reason: '$type 必须拒绝非法分类层级 $invalid',
        );
      }
    }
  });

  test('正式 API 拒绝响应中的非法分类层级，并保留 DTO 解析失败原因', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://contract.invalid'));
    final client = SesameApiClient(dio: dio, serializers: apiSerializers);
    addTearDown(() => dio.close(force: true));
    for (final invalid in [0, 3, -1, 1.5, true, 'invalid']) {
      dio.interceptors
        ..clear()
        ..add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'id': 'category',
                      'name': '餐饮',
                      'kind': 'expense',
                      'level': invalid,
                      'sort_order': 0,
                      'updated_at': '2026-10-13T00:00:00.000Z',
                      'version_token': 'version',
                    },
                  ],
                ),
              );
            },
          ),
        );
      await expectLater(
        client.getCategoriesApi().getLedgersByLedgerIdCategories(
          ledgerId: 'ledger',
        ),
        throwsA(
          isA<DioException>().having(
            (error) => error.error,
            'SDK 保留明确的 DTO 解析错误',
            isA<FormatException>().having(
              (error) => error.message,
              '合法值域',
              '分类层级必须为 1 或 2',
            ),
          ),
        ),
      );
    }
  });

  test('跨层 anyOf 联合中分类层级和其他数字字段均按契约往返', () {
    final raw = {
      'device_id': 'device',
      'changes': [
        {
          'mutation_id': 'mutation',
          'entity_type': 'category',
          'entity_id': 'category',
          'ledger_id': null,
          'sync_id': null,
          'base_revision': 7,
          'action': 'upsert',
          'updated_at': '2026-10-13T00:00:00.000Z',
          'payload': {
            'name': '餐饮',
            'kind': 'expense',
            'level': 2,
            'sort_order': 9,
            'icon': null,
            'parent_id': 'parent',
          },
        },
      ],
    };
    final model = apiSerializers.deserializeWith(
      PostSyncPushRequest.serializer,
      raw,
    )!;
    final category =
        model.changes.single.anyOf.values.values.single
            as PostSyncPushRequestChangesInnerAnyOf5;
    final changeModel =
        category.anyOf.values.values.single
            as PostSyncPushRequestChangesInnerAnyOf5AnyOf;
    expect(
      changeModel.payload.level,
      PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum.n2,
    );
    // 请求构造与生产 payload codec 一致：只登记实际选择的联合分支。
    final request = PostSyncPushRequest(
      (b) => b
        ..deviceId = model.deviceId
        ..changes = ListBuilder([
          PostSyncPushRequestChangesInner(
            (b) => b.anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5>(
              value: PostSyncPushRequestChangesInnerAnyOf5(
                (b) => b.anyOf =
                    AnyOf1<PostSyncPushRequestChangesInnerAnyOf5AnyOf>(
                      value: changeModel,
                    ),
              ),
            ),
          ),
        ]),
    );
    final wire =
        apiSerializers.serializeWith(PostSyncPushRequest.serializer, request)
            as Map;
    final change = (wire['changes'] as List).single as Map;
    expect((change['payload'] as Map)['level'], 2);
    expect((change['payload'] as Map)['sort_order'], 9);
    expect(change['base_revision'], 7);
    expect(
      ((raw['changes'] as List).single as Map)['payload'],
      containsPair('level', 2),
    );
  });

  test('非分类的同名字段与冻结删除 JSON 不被改写', () {
    final raw = {
      'level': 17,
      'protocol_version': 1,
      'nested': {'level': 2},
      'base_token': 'token',
      'extension': ['original', 9],
    };
    final object = apiSerializers.deserialize(
      raw,
      specifiedType: const FullType(JsonObject),
    );
    expect(
      apiSerializers.serialize(
        object,
        specifiedType: const FullType(JsonObject),
      ),
      raw,
    );
    expect(
      apiSerializers.serialize(42, specifiedType: const FullType(int)),
      42,
    );
  });
}
