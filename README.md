# Sesame Notes Mobile

Sesame Notes Mobile（芝麻记）是一款基于 Flutter 的离线优先记账应用，通过 OpenAPI 与 Sesame Notes 服务端同步；WebSocket 只发送拉取提示。

## 技术架构基线

- [技术架构基线](docs/TECHNICAL-ARCHITECTURE-BASELINE.md)：与独立的 sesame-notes 主仓库保持逐字一致；架构变更必须同步更新两份。

## 项目简介

- 本地账本与云端账本（云端同步，OpenAPI + WebSocket 增量同步）
- 交易、分类、统计、日历、AA 分摊、周期账单、多币种
- 共享账本、成员管理与邀请码（v1 仅手动输入邀请码，不配置 Deep Link）
- 第三方云备份：Supabase Storage / WebDAV / S3（加密备份，独立于业务同步）
- 应用锁、PIN、生物识别、记账提醒、多语言主题

## 环境要求

- Flutter 3.44.6（stable）
- Dart 3.12.2（`pubspec.yaml` 约束为 `^3.12.0`）
- Android 构建：JDK 17、compileSdk 36
- iOS 构建：macOS + Xcode
- Python 3（运行项目门禁脚本）

## 本地启动

```sh
flutter pub get
flutter run --flavor dev
```

## 质量检查

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze --no-pub
python scripts/test/api_contract_test.py
flutter test --test-randomize-ordering-seed=random
```

CI/Linux 环境使用 `python3`。设备级集成测试（真实后端链路）在 `integration_test/` 下，需模拟器或真机：

```sh
flutter test integration_test/real_api_roundtrip_test.dart
```

无设备的真实后端往返测试在 `e2e/` 下，不进入默认单元/组件测试：

```sh
flutter test e2e/real_backend_roundtrip_test.dart
```

GitHub Actions 的 `Backend E2E (manual)` 任务可显式传入一次性测试后端地址运行该链路。

## OpenAPI Client

- 契约固定为 `api/openapi/sesame-notes-api-v1.0.0.json`（后端生成物，不得手工修改）。SHA-256 固定 `A30764A04199DA4B57304DEB07DDC62CFD05CC51B4F7A50035C1F5B10C05278D`。
- 生成器固定 `openapitools/openapi-generator-cli:v7.24.0`（dart-dio），产物在 `packages/sesame_api_client`，生成代码不手工编辑。生成流程内置 `build_runner`（产出 built_value 的 `.g.dart`）与 `dart format`（产物格式合规），一键生成即完整可用。
- 重复生成校验（CI 步骤）：`powershell -File scripts/openapi/generate_api_client.ps1 -Check`
- `python scripts/test/api_contract_test.py` 校验 Artifact 哈希、版本、唯一 `operationId` 与统一错误模型。

## 平台构建

Android：

```sh
flutter build apk --debug --flavor dev
flutter build apk --release --flavor prod --target-platform android-arm64
```

- 标识：`com.sesame.notes`（namespace 与 applicationId）。
- 正式 Release 需要完整 `android/key.properties` 签名配置，缺失时构建失败。

iOS（macOS）：

```sh
flutter build ios --release --no-codesign
```

- Bundle ID：`com.sesame.notes`。
- 已声明 Face ID 用途说明与 Keychain 访问组。

## 目录结构

```text
lib/
├─ main.dart        # 启动入口
├─ core/            # api / identity / logging / storage
├─ sync/            # 增量同步（变更记录 / LWW 冲突 / 实时提示 / 重连）
├─ data/            # Drift 数据库、仓储与展示模型映射
├─ features/        # auth / ledgers / transactions / categories / statistics / settings
│                   # 每个 feature 内按 presentation / application / domain / infrastructure 分层
├─ shared/          # 共享 UI 组件、Provider、服务与 AA 分摊
├─ providers/       # 顶层启动编排聚合（单向依赖 features/*/application 与 shared/providers）
├─ router/          # 路由表（navigation/ 存路由常量）
├─ shell/           # 应用根 Widget
├─ theme/           # 设计令牌与主题
├─ l10n/            # 国际化（flutter gen-l10n 生成）
└─ utils/           # 纯 Dart 叶子工具
```
