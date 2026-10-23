import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 导入目标本候选：本子 id 与展示名。
typedef ImportBookOption = ({String id, String name});

/// 导入目标本选择解析结果：最终选中 id，以及候选列表是否已就绪。
typedef ImportBookSelection = ({String? selected, bool ready});

/// 解析导入目标本的最终选中：
/// - 候选未就绪（加载中 / 加载失败）→ 清空选择，且不覆盖已记住的选择；
/// - 原选中本仍在候选中 → 保留，列表刷新不跳回第一项；
/// - 选中本已失效或尚未选择 → 回落首个候选；
/// - 候选为空 → 清空选择。
ImportBookSelection resolveImportBookSelection(
  AsyncValue<List<ImportBookOption>> options,
  String? preferred,
) {
  // 与页面渲染共用同一套分支判定：拿不到候选列表就只有“未就绪”一种结论。
  final books = options.when(
    loading: () => null,
    error: (_, _) => null,
    data: (books) => books,
  );
  if (books == null) return (selected: null, ready: false);
  return (
    selected: books.any((book) => book.id == preferred)
        ? preferred
        : books.firstOrNull?.id,
    ready: true,
  );
}
