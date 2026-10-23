import 'dart:convert';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'category_conflicts_handler.dart';
import 'sync_assembly_context.dart';

/// 分类确认独立装配，HTTP 全程使用正式生成模型和同一会话客户端。
mixin CategoriesSyncAssembly on SyncAssemblyContext {
  @override
  late final CategoryConflictsHandler
  categoryConflicts = CategoryConflictsHandler(
    runtime,
    CategoryConflictPorts(
      list: (cursor) async {
        final response = await client.getCategoriesApi().getCategoryConflicts(
          status: 'all',
          cursor: cursor,
          limit: 100,
        );
        if (response.data == null) throw const FormatException('分类列表响应为空');
        return runtime.modelMap(
          response.data!,
          GetCategoryConflicts200Response.serializer,
        );
      },
      resolve: (id, frozenRequest) async {
        final response = await client
            .getCategoriesApi()
            .postCategoryConflictsByConflictIdResolve(
              conflictId: id,
              postCategoryConflictsByConflictIdResolveRequest: runtime.deser(
                frozenRequest,
                PostCategoryConflictsByConflictIdResolveRequest.serializer,
              ),
            );
        if (response.data == null) throw const FormatException('分类确认响应为空');
        return runtime.modelMap(response.data!, CategoryResolution.serializer);
      },
      project: (state, account) => projectionHandler.upsertCategory(
        runtime.deser(jsonEncode(state), Category.serializer),
        accountId: account,
      ),
    ),
  );
}
