# 测试与门禁（test）

仓库级质量门禁脚本，CI（`.github/workflows/test.yml`）与本地质量检查（见根 README）均从本目录执行。

## 测试内容汇总

### project_identity_test.py — 项目标识契约测试（52 项）

锁定项目品牌、平台工程与残留治理：

- **身份**：pubspec 必须为 `sesame_notes` v1.0.0；源码/测试不得导入旧包 `package:spitout`；依赖图与 CI 门禁必须识别新前缀
- **CI 约定**：普通 CI 只跑本地测试；设备集成测试位于 `integration_test/`，headless 真实后端往返位于 `e2e/` 并由手动 `backend_e2e` job 显式运行；OpenAPI 生成校验必须走 pwsh
- **残留治理**：临时探针、空 Provider 门面、noop post_processor、旧更新仓库引用、存储全盘权限申请、多余通知调度器、旧导出目录服务等一经出现即失败
- **备份包边界**：三个 adapter 入口不得 `export 'src/'`、主工程不得直连 adapter 内部实现；备份核心不得回潮 `database`/`realtime` 抽象
- **平台工程**：iOS 产品标识/生物识别声明、Android 通知权限与接收器、APK 品牌与签名门禁（无正式密钥禁止发布）、发布工作流只允许 Sesame-Notes 品牌

### api_contract_test.py — API 契约固定测试（7 项）

- 契约文件 `api/openapi/sesame-notes-api-v1.0.0.json` 必须与固定 SHA-256 一致（任何改动需显式升级哈希）
- 契约元数据：OpenAPI 3.0.3、版本 1.0.0、49 个 operationId 全局唯一；且全部 operation 必须覆盖统一错误状态（400/401/403/404/409/500），错误响应引用 `Error` 组件或与其字段兼容
- 交易 PATCH 的请求体必须要求 `base_revision`，禁止绕过乐观锁
- 交易 DELETE 的请求体必须要求 `base_revision`，禁止静默覆盖并发更新
- CI 工作流必须保留契约校验步骤，且根 README 必须写明同一份契约与哈希
- 生成器全量生成前必须清空受控输出目录（避免已删除端点残留）
- 生成器的 `-Check` 比较在 Windows 下不得携带字面引号，且只覆盖生成器负责的文件

### check_cycles_test.py — 依赖环检测脚本回归测试（8 项）

- 逐行解析 `import`/`export` 指令（注释后的多条声明不丢边）
- `part`/`part of` 指令归并正确（主库 ↔ 分片不误判为环）
- 根工程与 adapter 跨包互相导入时必须形成跨包环并失败
- `lib` 根直属文件（如 `main.dart`）归入 `<root>` 组，不与 `features` 等目录混在一起
- 跨目录回边必须检出（`core` → `data` → `core` 形成目录 SCC）
- 目录内自环（含基线豁免的 `data/models.dart` ↔ `data/db.dart` 门面伪环）必须豁免
- `main.dart` 与 `features` 互相导入时按 `<root>` ↔ `features` 成环
- 真实仓库（含 `packages/*`）的目录图必须是 DAG

### check_cycles.py — 静态依赖环检测工具（非测试，CI 直接执行）

- 扫描根工程 `lib/` 与 `packages/*/lib` 的业务源码（排除 `l10n/` 与 `*.g.dart`/`*.freezed.dart`）
- part 文件并入所属 library 再构图；文件级存在任何非平凡强连通分量（SCC）即失败并列出环内文件
- 文件级无环后追加目录级门禁：把依赖图按「package + lib 下第一层目录」收缩，目录之间的双向依赖同样判失败（目录内自环豁免）

### check_baseline_sync_test.py — 架构基线一致性门禁回归测试（8 项）

- 正文与权威副本哈希清单一致、正文漂移（错误信息含两端哈希）、清单缺失
- 清单内容非 64 位 SHA-256 或为空时拒绝
- 传入对端 checkout 时逐字比对两份正文
- 本仓正文与清单、与 `SESAME_NOTES_API_DIR` 指向的主仓 checkout 必须一致

### check_baseline_sync.py — 架构基线双仓一致性门禁（非测试，CI 直接执行）

- `docs/TECHNICAL-ARCHITECTURE-BASELINE.md` 必须与 `docs/TECHNICAL-ARCHITECTURE-BASELINE.sha256` 记录的权威副本哈希一致；正文改动未同步清单即阻断合并
- 传入 `--peer <目录>` 时与该 checkout 的基线正文逐字比对

## 运行方式

```sh
python scripts/test/project_identity_test.py
python scripts/test/api_contract_test.py
python scripts/test/check_cycles_test.py
python scripts/test/check_cycles.py
python scripts/test/check_baseline_sync_test.py
python scripts/test/check_baseline_sync.py
```

CI/Linux 环境使用 `python3`。
