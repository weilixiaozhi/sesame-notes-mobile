# 测试与门禁（test）

仓库级质量门禁脚本，CI（`.github/workflows/test.yml`）与本地质量检查（见根 README）均从本目录执行。

## 测试内容汇总

### api_contract_test.py — API 契约固定测试（7 项）

- 契约文件 `api/openapi/sesame-notes-api-v1.0.0.json` 必须与固定 SHA-256 一致（任何改动需显式升级哈希）
- 契约元数据：OpenAPI 3.0.3、版本 1.0.0、49 个 operationId 全局唯一；且全部 operation 必须覆盖统一错误状态（400/401/403/404/409/500），错误响应引用 `Error` 组件或与其字段兼容
- 交易 PATCH 的请求体必须要求 `base_revision`，禁止绕过乐观锁
- 交易 DELETE 的请求体必须要求 `base_revision`，禁止静默覆盖并发更新
- CI 工作流必须保留契约校验步骤，且根 README 必须写明同一份契约与哈希
- 生成器全量生成前必须清空受控输出目录（避免已删除端点残留）
- 生成器的 `-Check` 比较在 Windows 下不得携带字面引号，且只覆盖生成器负责的文件

## 运行方式

```sh
python scripts/test/api_contract_test.py
```

CI/Linux 环境使用 `python3`。
