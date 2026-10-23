import 'package:flutter/material.dart';

/// 删除模式共享状态机：一级分类管理页与子分类弹窗共用。
///
/// 仅收敛两处完全相同的状态字段与三个切换动作；两者的删除/迁移语义不同
/// （管理页 0/1/2 三策略含子分类提升，子分类弹窗仅 0/1），
/// 复核面板返回选择，各 State 执行对应的分类用例。
mixin CategoryDeleteModeState<T extends StatefulWidget> on State<T> {
  /// 是否处于删除模式
  bool isDeleteMode = false;

  /// 删除模式下选中的分类 UUID 集合。
  final Set<String> selectedCategoryIds = {};

  /// 删除策略（管理页 0=含二级/1=迁移/2=提升子分类；子分类弹窗 0/1）
  int deleteOption = 0;

  /// 进入删除模式
  void enterDeleteMode() {
    setState(() {
      isDeleteMode = true;
      selectedCategoryIds.clear();
      deleteOption = 0;
    });
  }

  /// 退出删除模式
  void exitDeleteMode() {
    setState(() {
      isDeleteMode = false;
      selectedCategoryIds.clear();
    });
  }

  /// 切换当前分类选择并通知界面更新。
  void toggleSelect(String categoryId) {
    setState(() {
      if (selectedCategoryIds.contains(categoryId)) {
        selectedCategoryIds.remove(categoryId);
      } else {
        selectedCategoryIds.add(categoryId);
      }
    });
  }
}
