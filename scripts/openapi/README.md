# OpenAPI 客户端生成（openapi）

从固定契约生成 / 校验 Sesame Notes Dart API 客户端（dart-dio），产物在 `packages/sesame_api_client`（生成代码不手工编辑）。

## 用法（仓库根目录执行）

```powershell
# 预览：输出到 build/openapi_preview（git 忽略）
powershell -File scripts/openapi/generate_api_client.ps1 -Preview

# 正式生成：输出到 packages/sesame_api_client（提交）
powershell -File scripts/openapi/generate_api_client.ps1

# 可重复校验：临时目录重新生成 + build_runner，与已提交输出 diff，不一致则退出码非 0
powershell -File scripts/openapi/generate_api_client.ps1 -Check
```

## 组成

- `generate_api_client.ps1` — 一键生成/校验（固定生成器镜像 `openapitools/openapi-generator-cli:v7.24.0`）
- `normalize_openapi.mjs` — 契约规范化：把后端 TypeBox 的 anyOf 单值枚举与纯 null 表达收敛为 dart-dio 可消费的标准 enum / nullable

## 设计约束

- 契约固定为 `api/openapi/sesame-notes-api-v1.0.0.json`（后端生成物，不得手工修改；SHA-256 由 `scripts/test/api_contract_test.py` 钉死）
- 生成器 tag 固定，杜绝静默跟随上游模板变化；`pubspec.lock` 提交锁定保证 build_runner 产物可复现
