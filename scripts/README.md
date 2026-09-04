# 项目工具脚本

本目录包含项目的各种开发工具脚本。

## 📁 目录结构

```
scripts/
├── android_keystore/   # Android 发布签名 keystore 生成工具
│   ├── generate_android_keystore.ps1   # Windows (PowerShell)
│   ├── generate_android_keystore.sh    # macOS / Linux (Bash)
│   └── README.md
├── audit/              # 孤儿/未接线扫描
│   ├── orphans.dart    # 死路由 / 孤儿页面 / 未用 provider
│   └── README.md
├── i18n/               # 国际化翻译管理工具
│   ├── align_arb.dart      # ARB 对齐（键序/元数据/缩进）
│   ├── check_status.dart   # 检查与清理（翻译完整性 / 多余 keys / 未使用 keys）
│   └── README.md
├── launcher_icons/     # 启动图标生成工具
│   ├── rasterize_svg.dart
│   └── README.md
├── openapi/            # OpenAPI 客户端生成/校验
│   ├── generate_api_client.ps1
│   ├── normalize_openapi.mjs
│   └── README.md
├── test/               # 测试与门禁（CI 质量闸）
│   ├── api_contract_test.py
│   └── README.md
└── README.md           # 本文件
```

## 🛠️ 工具分类

### 🔑 android_keystore — keystore 生成

一键生成 Android 发布 keystore 并写入 `android/key.properties`：

- **generate_android_keystore.ps1** — Windows 版（PowerShell）
- **generate_android_keystore.sh** — macOS / Linux 版（Bash），与 .ps1 等价

详见 [android_keystore/README.md](android_keystore/README.md)。

### 🔍 audit — 孤儿/未接线扫描

- **orphans.dart** — 扫描死路由、孤儿页面、未用 provider（l10n 键检查在 i18n 工具中）

详见 [audit/README.md](audit/README.md)。

### 📝 i18n — 国际化翻译管理

- **align_arb.dart** — 对齐三个 ARB 文件：键顺序、`@` 元数据、`@@locale`、4 空格缩进
- **check_status.dart** — 综合检查与清理：翻译完整性、多余 keys、未使用 keys

详见 [i18n/README.md](i18n/README.md)。

### 🖼️ launcher_icons — 启动图标生成

- **rasterize_svg.dart** — 将 SVG 源图标栅格化为 flutter_launcher_icons 所需的 PNG

详见 [launcher_icons/README.md](launcher_icons/README.md)。

### 📡 openapi — OpenAPI 客户端生成

从固定契约生成 / 校验 Dart API 客户端（dart-dio），产物在 `packages/sesame_api_client`：

- **generate_api_client.ps1** — 一键生成 / `-Check` 可重复校验
- **normalize_openapi.mjs** — 契约规范化（枚举 / nullable 收敛）

详见 [openapi/README.md](openapi/README.md)。

### 🧪 test — 测试与门禁（CI 质量闸）

仓库级质量门禁脚本，CI 与本地质量检查均从本目录执行：

- **api_contract_test.py** — API 契约固定测试（哈希钉死 / 元数据 / 统一错误模型 / 乐观锁 / 生成器门禁，7 项）

详见 [test/README.md](test/README.md)。

## 🚀 快速开始

```bash
# 生成 Android 发布 keystore（Windows）
powershell -ExecutionPolicy Bypass -File scripts/android_keystore/generate_android_keystore.ps1

# 生成 Android 发布 keystore（macOS / Linux）
bash scripts/android_keystore/generate_android_keystore.sh

# 孤儿/未接线扫描（死路由 / 孤儿页面 / 未用 provider）
dart scripts/audit/orphans.dart

# i18n 检查与清理
dart scripts/i18n/check_status.dart

# i18n 对齐（新增/删除翻译键后运行）
dart scripts/i18n/align_arb.dart

# 图标栅格化（先改 SVG，再执行）
flutter test scripts/launcher_icons/rasterize_svg.dart

# 质量门禁（本地与 CI 一致）
python scripts/test/api_contract_test.py

# OpenAPI 客户端生成校验
powershell -File scripts/openapi/generate_api_client.ps1 -Check
```

## 💡 添加新工具

如果要添加新的工具分类，建议的结构：

```
scripts/
├── category_name1/
│   ├── tool.dart
│   └── README.md
├── category_name2/
│   ├── tool.dart
│   └── README.md
└── README.md
```

每个工具目录应包含：
1. 工具脚本文件
2. README.md 说明文档
3. 必要的配置文件
