import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/support/category_row_tree.dart';

/// 分类目录、选择树与关联交易的只读端口，不提供写入或事务控制能力。
abstract interface class CategoryQueryRepository {
  /// 读取当前账号目录，指定账本时解析本机目录或账本所有者的共享镜像。
  Future<List<CategorySnapshot>> getAllCategories({String? ledgerId});

  /// 按导出账本的分类域读取分类，缺省只返回当前账号目录。
  Future<List<CategorySnapshot>> getAllCategoriesIncludingShared({
    String? ledgerId,
  });

  /// 在指定分类域中按稳定身份读取一个有效分类。
  Future<CategorySnapshot?> getCategoryById(
    String categoryId, {
    String? ledgerId,
  });

  /// 批量读取同一分类域内的有效分类，避免逐条查询。
  Future<Map<String, CategorySnapshot>> getCategoriesByIds(
    Iterable<String> ids, {
    String? ledgerId,
  });

  /// 按类型读取一级分类，并保持目录的排序规则。
  Future<List<CategorySnapshot>> getTopLevelCategories(
    String kind, {
    String? ledgerId,
  });

  /// 读取当前目录中指定父分类的有效子分类。
  Future<List<CategorySnapshot>> getSubCategories(String parentId);

  /// 读取当前目录中可用于记账的分类。
  Future<List<CategorySnapshot>> getUsableCategories(String kind);

  /// 按账本权限及层级规则过滤可选分类，共享账本使用所有者镜像。
  Future<List<CategorySnapshot>> filterCategoriesForLedgerPicker(
    List<CategorySnapshot> all, {
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  });

  /// 在相同类型及父级下判重，指定账本时先验证可编辑目录。
  Future<bool> isCategoryNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
    String? ledgerId,
  });

  /// 判断当前分类域内是否存在有效子分类。
  Future<bool> hasSubCategories(String categoryId);

  /// 统计精确分类域及账本中的有效交易数量。
  Future<int> getTransactionCountByCategory(
    String categoryId, {
    String? ledgerId,
  });

  /// 监听分类及直属子分类合计笔数，未知账本归属以错误阻断。
  Stream<List<({CategorySnapshot category, int transactionCount})>>
  watchCategoriesWithCount();

  /// 监听固定账本的选择树，只响应分类、共享镜像及账本变化。
  Stream<CategoryRowTree> watchCategoryPickerTree({
    required String ledgerId,
    required String kind,
  });

  /// 监听指定分类和它的直属子分类，保持同一分类域。
  Stream<List<CategorySnapshot>> watchCategoryWithSubs(
    String categoryId, {
    String? ledgerId,
  });

  /// 监听分类关联交易，按需包含直属子分类的交易。
  Stream<List<TransactionSnapshot>> watchTransactionsByCategory(
    String categoryId, {
    String? ledgerId,
    bool includeSubCategories = false,
  });
}
