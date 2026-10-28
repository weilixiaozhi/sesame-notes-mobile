# 项目工具脚本

命令均从仓库根目录执行，所需 Flutter、Dart、Python、Node.js、Docker、PowerShell、JDK 等须已可用。临时产物放在根目录 `Temp/`；生成命令会写文件，完成后应审阅差异。

入口：[Android 构建](#android-构建) · [签名](#android-签名) · [图标](#图标与品牌资源) · [OpenAPI](#openapi-客户端) · [翻译](#翻译维护) · [健身资料](#健身资料) · [审计](#未引用候选扫描) · [检查与验收](#检查与验收)

## Android 构建

```powershell
pwsh -NoProfile -File scripts/build_android.ps1 -Environment test
pwsh -NoProfile -File scripts/build_android.ps1 -Environment prod
pwsh -NoProfile -File scripts/build_android.ps1 -Environment test -ValidateOnly
```

`test` 对应 `envTest/debug`，安装身份为 `com.sesame.notes.test.debug`；`prod` 对应 `prod/release`，安装身份为 `com.sesame.notes`。正式包需要自己的[签名材料](#android-签名)。

没有服务器时直接运行即可：默认私有配置不存在时仅注入 `APP_ENV`，安装后可使用本地功能。需要账号服务时，将 `config/*.example.json` 复制为对应的 `config/*.local.json` 并填写服务器地址；私有配置被 Git 忽略，真实地址、凭据和签名材料不能写回示例文件。

| 参数或配置                 | 规则                                                                                                                        |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| `-ConfigPath`              | 指定绝对路径或相对仓库根目录的路径；默认读取对应的 `.local.json`。显式指定的文件缺失或配置非法时，在调用 Flutter 前失败。   |
| `-ValidateOnly`            | 仅校验配置，不构建。错误日志为 `Temp/android-build-errors.log`。                                                            |
| `APP_ENV`                  | 必须与 `-Environment` 一致。                                                                                                |
| `API_BASE_URL`             | 可为空；为空时登录、注册提示未配置账号服务器，本地功能可用。正式包提供地址时要求 HTTPS；Nginx 到后端的内部连接可使用 HTTP。 |
| `UPDATE_MANIFEST_URL`      | 空字符串禁用应用内更新；启用时填写 HTTPS 清单地址，测试包必须留空。                                                         |
| `-DartDefine 'NAME=value'` | 传入其他编译参数，不能覆盖 `APP_ENV`。                                                                                      |

直接运行 Flutter：本地模式用 `flutter run --flavor envTest --dart-define=APP_ENV=test`，有配置时用 `flutter run --flavor envTest --dart-define-from-file=config/test.local.json`。原生 Gradle 任务须通过 `-Pdart-defines` 传入编码后的环境：test 为 `QVBQX0VOVj10ZXN0`，prod 为 `QVBQX0VOVj1wcm9k`。单元测试用 `flutter test --no-pub`，无需私有服务器配置。

[手动发布工作流](../.github/workflows/release.yml)读取可选 Secrets `API_BASE_URL`、`UPDATE_MANIFEST_URL`，留空分别表示本地使用、禁用更新；签名 Secrets 必须配置。接口契约在本地更新，见 [OpenAPI 客户端](#openapi-客户端)。

Windows 构建在本次进程的 `JAVA_TOOL_OPTIONS` 中将 Java 本地域套接字目录设为根 `Temp/`，结束或失败后恢复原值，不修改全局 Java 或网络配置。

## Android 签名

[签名工具](android_keystore/generate_android_keystore.ps1)使用 PowerShell 7 与已有 JDK `keytool` 创建新签名，不构建或发布 APK。

```powershell
pwsh -NoProfile -File scripts/android_keystore/generate_android_keystore.ps1
pwsh -NoProfile -File scripts/android_keystore/generate_android_keystore.ps1 -OutFile android/app/new-release.keystore -Alias release -Validity 7300
```

`-OutFile` 默认 `android/app/release.keystore`，相对仓库根解析，也接受外部绝对路径；`-Alias` 默认 `release` 且不能为空；`-Validity` 默认 3650 天、范围 1–36500；`-DName` 默认 `CN=Unknown, OU=Dev, O=Org, L=City, S=State, C=CN`，应填写实际证书身份。

密码优先读取 `KEYSTORE_PASSWORD`、`KEY_PASSWORD`，缺失时隐藏输入。前者留空生成随机密码，后者留空复用前者；均至少 6 个字符，经环境变量传给 keytool，不打印密码。格式固定 RSA 2048 位与 JKS，支持不同 store/key 密码；JDK 的 PKCS12 建议不表示生成失败。

目标 keystore 或 `android/key.properties` 任一已存在即拒绝，不覆盖或转换旧签名。keytool 失败不写属性文件，若已产生新密钥须自行检查处理。属性文件固定写入 `android/`，`storeFile` 相对 `android/app/` 解析，跨盘使用绝对路径；属性按 Java Properties 转义，以无 BOM 的 ASCII 保存。密钥与含明文等价凭据的属性文件应加密备份，不能提交 Git；恢复已有签名不能靠重新生成。发布工作流从 Secrets 恢复签名，不调用此生成器。

## 图标与品牌资源

品牌源文件为 [assets/app_logo.svg](../assets/app_logo.svg)。应用内 [AppLogo](../lib/shared/widgets/app_logo.dart)直接渲染 SVG；桌面图标先栅格化，再按 [pubspec.yaml](../pubspec.yaml)生成平台资源。

```powershell
flutter test scripts/launcher_icons/rasterize_svg.dart
flutter pub run flutter_launcher_icons
```

第一条虽使用 `flutter test`，实际会覆盖 `assets/flutter_launcher_icons/` 的两张 1024×1024 PNG：透明的 `adaptive_foreground.png` 用于 Android 自适应前景和主题图标，白底的 `launcher_legacy.png` 用于传统 Android 图标和 iOS。脚本按 SVG 实际尺寸等比缩放并居中；Flutter 依赖须事先解析完成。

第二条生成 `android/app/src/main/res/` 与 `ios/Runner/Assets.xcassets/AppIcon.appiconset/`。当前 Android 背景为白色，前景及主题层均内缩 13%；主题图标按 alpha 轮廓着色，不保留 RGB 配色和不透明区域内部细节。iOS 使用 `remove_alpha_ios: true` 去除透明通道。Android 各风味共用 `@mipmap/ic_launcher`，iOS 资源标识为 `AppIcon`；具体尺寸、倍率以平台资源配置为准。

SVG、中间 PNG、平台图标须一起审阅并提交。检查 Android 圆形、圆角矩形遮罩及主题图标、iOS 各尺寸图标，并检查欢迎、登录、注册和应用锁页面的 `AppLogo`；SVG 留白与平台内缩共同决定显示大小。默认头像 `assets/Default avatar.png` 独立维护，检查 `MemberAvatar` 的圆形裁切。原生启动画面使用 iOS `LaunchImage.imageset`/`LaunchScreen` 和 Android `launch_background.xml`，上述命令不修改其图片或布局。

## OpenAPI 客户端

[生成器](openapi/generate_api_client.ps1)读取 `api/openapi/sesame-notes-api-v1.0.0.json`，规范化后通过固定的 OpenAPI Generator 7.24.0 生成 Dart SDK 及 `.g.dart`，不生成 SDK README 或 API/model 文档。字段以本仓冻结契约为准。需要 Node.js、Docker、Dart；检查模式另需 Git。

Windows 必须使用 PowerShell 5.1，Linux/macOS 将 `powershell.exe` 换成 `pwsh`：

```powershell
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1 -Preview
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1 -Check
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1
```

`-Preview` 保留预览；`-Check` 比较生成结果且不替换正式 SDK，两者互斥；无开关时生成及编译成功才替换 `packages/sesame_api_client`。已有生成器镜像与 Dart 缓存时可追加 `-Offline`，禁止拉取镜像和 Pub 联网解析；依赖缺失直接失败，保留正式 SDK。

每轮独占 `Temp/openapi-generation/{input,preview,check}/<runId>`，只清理自身目录。比较范围是 `.gitignore`、`.openapi-generator`、`.openapi-generator-ignore`、`analysis_options.yaml`、`lib`、`pubspec.yaml`，要求两侧均无 README/doc；忽略缓存和 `pubspec.lock`。契约变更须先审阅定义，再同步 Artifact 与哈希，不能仅改哈希让检查通过；相关验证见[检查与验收](#检查与验收)。

### 本地更新接口契约

接口变化作为本地开发任务一并处理。开发者和开源贡献者使用同一流程：

1. 在服务端完成接口修改，运行 `pnpm --filter @sesame-notes/api openapi:generate` 更新服务端的 `packages/api-contract/openapi.json`。
2. 将该文件同步到客户端的 `api/openapi/sesame-notes-api-v1.0.0.json`，并将 `scripts/test/api_contract_test.py` 的 `EXPECTED_SHA256` 更新为实际文件的 SHA-256。摘要用于检查文件一致性，不是需要手动选择的 Git 提交版本。
3. 使用上方本地生成器更新 `packages/sesame_api_client`，运行 `python -B scripts/test/api_contract_test.py` 及生成器 `-Check`，审查接口定义和生成代码差异后，随功能修改一起提交。

只修改服务端内部逻辑、契约内容没有变化时，无需更新客户端契约和生成代码。普通构建使用本仓已提交的契约与 SDK，不访问服务端源码；维护时由开发者明确指定自己的服务端文件来源。流程不需要 GitHub 来源表单、公开/私有选择、专用读取凭据或同步 PR，仓库公开状态不影响本地更新。生成器所需工具和缓存须事先准备，离线运行使用 `-Offline`。

## 翻译维护

工具使用 Dart 标准库，以 [l10n.yaml](../l10n.yaml)指定的 `app_en.arb` 为模板，维护 en、zh、zh_TW。

```sh
dart scripts/i18n/check_status.dart
dart scripts/i18n/align_arb.dart
flutter gen-l10n
```

[check_status.dart](i18n/check_status.dart)按模板键交集统计完成度，另列缺失、空白/null、多余键及未使用候选。每种清理分别询问，仅回答 `y/yes` 才删除相应键和 `@key` 元数据，回车跳过。未使用检测扫描 `lib/`、`test/`，排除生成的 `lib/l10n/`，匹配完整标识符但仍包含注释、字符串和测试引用；候选需人工复核。发现候选不设置失败退出码，不是 CI 完整性门禁。

[align_arb.dart](i18n/align_arb.dart)会直接重写三份 ARB：按 en 顺序排列、4 空格缩进；写前检查所有语言，缺少模板翻译或值为 null 时失败；保留已有全局/消息元数据和额外键，仅缺失元数据时按 en → zh → zh_TW 补齐，缺少 `@@locale` 时补语言代码。文件顺序写入，无文件系统事务。工具不翻译或自动生成 Dart；审阅 ARB 差异后执行 `flutter gen-l10n` 并验证受影响功能。

## 健身资料

[assets/fitness/exercises.json](../assets/fitness/exercises.json)是动作身份、多语言名称、教学、媒体路径及来源提交的正式资料。保持已发布动作 ID 稳定，核对来源与媒体后重新生成同步身份校验表：

```sh
python scripts/fitness/generate_catalog_registry.py
dart format lib/data/models/fitness_catalog_registry.dart
flutter test test/data/fitness_rules_test.dart test/data/fitness_catalog_search_test.dart --no-pub
```

第一条写入 `lib/data/models/fitness_catalog_registry.dart`。服务端仓库的 `apps/api/scripts/generate-fitness-catalog.ts` 从同一资料生成后端与共享契约目录，其 `packages/api-contract/fitness-catalog.json` 应同步到本仓 `api/openapi/fitness-catalog.json`；本地测试验证动作规则与目录搜索。

## 未引用候选扫描

```sh
dart scripts/audit/orphans.dart
```

[扫描器](audit/orphans.dart)只读 `lib/`，终端输出路由、页面、Provider、公共方法候选，不删除文件或生成报告。路由按 `Routes.<名称>` 在定义文件外计数（注册也算）；页面限 `/presentation/*_page.dart` 中首个匹配的 `…Page`，按类名在自身文件外计数；Provider 与 Repository/Service/Actions/Coordinator 公共方法按全 `lib/` 文本计数，声明也计入，出现不超过一次才列候选。

不扫描 `packages/`、`test/`；生成文件参与引用计数，`.g.dart` 仅从公共方法定义候选中排除。正则不解析符号身份或 import/export 图、SCC，注释、字符串、同名符号、动态调用可能造成误报或漏报。候选需人工复核，不能证明 Provider 有实际消费者；发现候选不使检查失败，读取等运行错误仍可能中断。工具未作为 CI 失败门禁。

## 检查与验收

自动测试保留业务规则、数据持久化、权限与账号隔离、同步和接口契约；界面样式、布局和页面交互通过人工验收。以下检查依赖已安装工具，失败返回非零。

| 命令                                                           | 范围与边界                                                                                                                                                              |
| -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `python -B scripts/test/update_manifest_test.py`               | 用隔离夹具验证正式 APK 版本与更新摘要。                                                                                                                                 |
| `python scripts/test/api_contract_test.py`                     | 固定 Artifact 摘要、枚举、OpenAPI 元数据、统一错误和乐观锁；同时验证 SDK 规范化后的业务约束。需 Python 3、Node.js。 |

[规范化测试](openapi/normalize_openapi.test.mjs)验证转换约束、幂等性和源文件不变。统一错误检查匹配 Error 引用或必填 `code/message/request_id`，不验证所有字段类型。

原生通知排期单测及其他检查入口见[手动测试工作流](../.github/workflows/test.yml)。

直接验收已有 APK 可用 `python -B scripts/check_apk_architecture.py --apk <APK路径> --abi arm64-v8a`。生成更新清单用 `python -B scripts/generate_update_manifest.py --apk <正式APK路径> --version <版本> --repository <owner/repository> --notes <发布说明文件> --output <清单路径>`，它会校验命名、计算摘要并写输出文件。

### Android 通知实机验收

[独立探针](../e2e/notification_delivery_probe.dart)只接受 `APP_ENV=test` 与 `com.sesame.notes.test.probe`，不加载账号、数据库或服务端连接。取得设备所有者授权后安装：

```powershell
flutter build apk --profile --flavor envTestProbe --target-platform android-arm64 --no-pub --dart-define-from-file=config/test.local.json --target e2e/notification_delivery_probe.dart
adb install -r build/app/outputs/flutter-apk/app-envtestprobe-profile.apk
adb shell am start -n com.sesame.notes.test.probe/com.sesame.notes.MainActivity
```

在系统界面允许测试包通知、闹钟与提醒权限，后台运行与自启动分开验收；生产包设置保持独立。

1. “四条业务通知”在 60 秒后发送记账、两个日期 ID 的纪念日和健身休息提醒，分别在前台、最近任务上滑、一键清理后核对四个 ID 与正文；正式业务中的同日纪念日仍合并正文。
2. “每日记账重复”登记下一分钟任务，关闭进程后检查到期投递及次日任务由原生接收器续期；它与第一项共用记账 ID，分轮测试。
3. `exactAllowWhileIdle`、`alarmClock` 按钮只作 ROM 调度对照；产品的系统下一闹钟入口另行检查，只应打开应用，不能提前发通知。
4. 登记后检查 `adb shell dumpsys alarm` 的真实任务、时刻与窗口；上滑后结合 `adb shell pidof com.sesame.notes.test.probe`、`adb shell dumpsys package com.sesame.notes.test.probe` 的 `stopped` 状态及 `adb shell dumpsys notification` 核对，登记缓存不等于系统任务仍存在。部分厂商将上滑或后台限制视为强行停止，禁用自启动也可能阻止广播。
5. `am force-stop` 仅作独立限制对照，会清除系统任务；产品重新打开后才恢复未来提醒。探针启动和恢复不自动重排。“读取通知中心和缓存”可查看系统通知及登记/到期时间；原生日志标签为 `ReminderAlarm`、`FitnessRestAlarm`。

结束用“清理本探针 ID”撤销任务，在授权范围内卸载测试包；不能通过清除生产包数据复现问题。

### PDF 字符保真验收

需要 Python 3 与已有 `pypdf`，先由正式 writer 与已入库字体生成样本，再验收：

```sh
flutter test test/data/memo_document_test.dart --no-pub --dart-define=MEMO_PDF_PROBE=true
python scripts/test/memo_pdf_probe.py Temp/memos-p0
```

生成 `probe.pdf`、`pdf-expectations.json` 后，[验收器](test/memo_pdf_probe.py)验证长中英文、Unicode、首尾空格、空段落和嵌入字体空白轮廓，写入 `pdf-result.json`；任一检查失败返回非零。PDF 存在不代表保真；此项按需运行，不属于常规 CI。
