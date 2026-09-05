# Git 提交钩子

提交前格式门禁：对暂存区 Dart 文件执行 `dart format`（写模式）并重新暂存，
保证入库代码与 CI 格式门禁一致。对人工编辑与 AI 编码助手的提交同样生效。

## 安装

每个克隆只需执行一次：

```bash
git config core.hooksPath scripts/git-hooks
```

## 生效范围

- 仅处理本次提交暂存的新增/修改 `.dart` 文件（删除类变更跳过）；
- 未安装 `dart` 命令时阻止提交并提示；
- 格式化后自动重新 `git add`，提交内容即格式化后的版本。

## 说明

钩子只做格式规整，不跑 analyze/test——完整门禁按 CI 与开发流程规范执行。
