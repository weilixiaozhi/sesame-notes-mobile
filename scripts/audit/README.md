# 孤儿/未接线扫描

找出「注册了但没有入口」的死代码候选。

## 用法

```bash
dart scripts/audit/orphans.dart
```

## 扫描范围

1. **死路由** — `Routes.xxx` 在路由文件之外零引用(注册了但没人跳转,如历史上的 `/backup/restore`)
2. **孤儿页面** — `presentation/**/*_page.dart` 的页面类在自身文件之外零引用
3. **未用 provider** — lib 中声明的 Provider 全库仅剩声明行

l10n 的未使用/多余键检查与清理由 [i18n/check_status.dart](../i18n/check_status.dart) 负责,本脚本不重复扫描。

## 说明

结果为启发式候选清单,需人工确认。常见误报:动态路由拼接、测试专用注入、字符串键。
