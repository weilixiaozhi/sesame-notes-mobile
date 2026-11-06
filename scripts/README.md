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

[生成器](openapi/generate_api_client.ps1)读取 `api/openapi/sesame-notes-api-v1.0.0.json`，规范化后通过固定的 OpenAPI Generator 7.24.0 和 Dart 3.13.2 stable 生成 Dart SDK 及 `.g.dart`，不生成 SDK README 或 API/model 文档。字段以本仓冻结契约为准。需要 Node.js、Docker及指定 Dart；检查模式另需 Git。缺少所需工具时直接失败，不自动安装。

Windows 必须使用 PowerShell 5.1，Linux/macOS 将 `powershell.exe` 换成 `pwsh`：

```powershell
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1 -Preview
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1 -Check
powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1
```

`-Preview` 保留预览；`-Check` 比较生成结果且不替换正式 SDK，两者互斥；无开关时生成及编译成功才替换 `packages/sesame_api_client`。已有生成器镜像与 Dart 缓存时可追加 `-Offline`，禁止拉取镜像、生成容器联网和 Pub 联网解析；依赖缺失直接失败，保留正式 SDK。

每轮独占 `Temp/openapi-generation/{input,preview,check}/<runId>`，只清理自身目录。空模板的 `test` 依赖在本轮目录内确定性移除，随后复制版本化的 [完整生成依赖锁](openapi/generator.pubspec.lock)，以 `dart pub get --enforce-lockfile` 解析；`-Offline` 同时要求 Pub 仅用本机缓存。解析与生成结束均校验锁的 SHA-256，工具版本、锁或缓存不满足时保留正式 SDK，不回落到最新可用依赖。Dart 版本也固定以避免格式化差异。

比较范围是 `.gitignore`、`.openapi-generator`、`.openapi-generator-ignore`、`analysis_options.yaml`、`lib`、`pubspec.yaml`，要求两侧均无 README/doc；缓存不参与比较，`pubspec.lock` 由上述版本化输入单独校验。升级生成工具时，应一并审阅 Dart 版本、生成镜像和完整锁，再在两个独立 Temp 工作区离线重生成比较；不能靠放宽锁校验消除漂移。契约变更须先审阅定义，再同步 Artifact 与哈希，不能仅改哈希让检查通过；相关验证见[检查与验收](#检查与验收)。

只验证依赖准备、版本保护和锁漂移拒绝，不调用 Docker/Pub 或改写 SDK：

```powershell
node --test scripts/openapi/generator_dependencies.test.mjs
```

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

## 只读架构与符号审计

在仓库根目录使用已经解析的本地依赖执行，不运行生成器、不连接设备或服务、不安装工具：

```powershell
dart scripts/audit/architecture.dart
dart scripts/audit/architecture.dart --symbols --json > Temp/architecture-audit.json
dart scripts/audit/architecture_test.dart
```

重定向前自行确认目标文件不存在；所有一次性报告存放在本仓 `Temp/`，不要覆盖既有报告。工具本身只读源码，默认输出覆盖、手写生产 library SCC、明确边界违规和解析失败。`--symbols` 使用固定的 analyzer 12.1.0 解析元素身份和消费者，JSON 另含全部 import/export/条件分支/part、目录 SCC、模块引用广度、声明及零显式消费者候选。首次完整符号分析比快速边界检查耗时更长。

包路径取当前 `.dart_tool/package_config.json` 的实际根和 `packageUri`，支持本地包目录与包名不同、URI 有无末尾斜杠；相对路径归一化。快速模式双向核对 `part` 与 `part of` 的 URI 或 library 名称归属，缺少声明、归属错误及孤立 part 都使解析失败；合法组成关系归并到同一 library，不能机械构成普通循环。`show`、`hide`、export 转发、构造/注解引用按解析元素记录，隐式扩展成员调用同时消费所属 extension。生成 part 和生成 SDK 参与消费核查，手写生产主图分别排除生成物、测试、工具及 e2e。模块边的强度为不同引用源 library 数，目录聚合环不能等同真实文件循环。

明确边界按职责失败：core 不依赖 features/shared/infrastructure/顶层 providers；API 传输不反引 shared/features；启动端口不读取顶层启动实现或 features；共享领域不依赖业务实现/状态装配；领域规则不读取 presentation/application/共享 Provider；备份核心不依赖应用或具体备份服务商。生成边同样接受对应边界检查。没有按现有违规个数建立白名单或阈值。退出码 `0` 表示本次边界和解析检查完成，`1` 表示明确边界违规，`2` 表示参数/依赖配置/语法/符号解析不完整；候选数及 SCC 数不控制退出码。

零显式消费者只作为人工候选。接口虚分派、框架回调、原生/后台入口、动态注册、JSON约定、资源、跨仓 API/Web/Admin 消费和历史数据/备份兼容仍需单独核查。条件分支全部进入编译图，符号消费对应当前分析配置，不能证明每种目标平台的运行行为。当前工具不删除任何声明，不自动收窄出口，不以扫描成功证明绝对不存在死代码。`orphans.dart` 的文本扫描仍是启发式补充，不能代替元素身份分析。

语义回归脚本只在 `Temp/` 建立独占夹具，验证包名映射、无末尾斜杠 URI、show/hide 转发、同名符号、命名 extension、条件导入、生成 part 消费、只读性及真实边界失败，结束清理本次夹具。手动 Test 工作流配置了快速边界检查和语义回归；工作流仍仅由 `workflow_dispatch` 触发，启动或重跑须明确同意，本工具不会触发 CI。

## iOS 环境与安装身份

共享 Xcode 方案 `test`、`prod` 分别包含 Debug、Profile、Release 三种配置。测试环境使用 `com.sesame.notes.test`，正式环境保持 `com.sesame.notes`；钥匙串组随 Bundle ID 分开，两个应用可以并装。默认 Runner 方案的 Debug 使用测试身份，Profile/Release 使用正式身份。

在已有 macOS/Xcode/Flutter 环境中，从仓库根目录运行：

```sh
flutter run --flavor test --dart-define-from-file=config/test.local.json
flutter build ios --release --flavor prod --dart-define-from-file=config/prod.local.json --no-pub
```

私有地址继续从各自忽略的配置文件注入，正式签名沿用开发者自己的 Xcode 配置。`ios/Flutter/Environment*.xcconfig` 将 `APP_ENV` 与原生身份绑定；编译前的 `scripts/ios/check_environment.py` 要求 Xcode 配置、Bundle ID、全部 `APP_ENV` 声明一致，冲突或缺失直接失败，不打印配置值。不要把测试配置文件用于正式方案。

不依赖 Xcode 的配置回归：

```powershell
python -B scripts/test/ios_environment_test.py
```

这项回归覆盖配置、共享方案和混用拒绝规则；iOS 签名、打包、系统权限与真机并装仍应在 macOS/iOS 环境验收。方案和配置的对应方式见 [Flutter 官方说明](https://docs.flutter.dev/deployment/flavors-ios)。
## Android R8 规则与 APK 只读测量

正式包只为 Flutter 反射注册入口、通知持久化模型字段/构造器及序列化元数据配置应用规则。通知样式的简单类名、枚举与字段名参与历史 Gson 缓存，不能随混淆改名。Flutter JNI 与类级 `@Keep` 入口由 Android 默认规则和 AndroidX 消费者规则保护，清单组件由 AAPT 生成规则保留；升级 Flutter、AGP 或插件时需要重新核对合并配置与产物。

使用已经安装的 Python 标准库读取现有 APK、同轮 R8 输出与该 SDK 的 release 引擎 JAR：

```powershell
python -B scripts/audit/apk_r8_report.py --apk <旧APK> --mapping-dir <旧构建mapping目录> --engine-jar <FlutterSDK>/bin/cache/artifacts/engine/android-arm64-release/flutter.jar --json-output Temp/r8-baseline.json
python -B scripts/audit/apk_r8_report.py --apk <新APK> --mapping-dir <新构建mapping目录> --engine-jar <FlutterSDK>/bin/cache/artifacts/engine/android-arm64-release/flutter.jar --baseline Temp/r8-baseline.json --json-output Temp/r8-current.json
```

`mapping目录`应同时包含 `configuration.txt`、`mapping.txt`、`seeds.txt`、`usage.txt`。报告文件必须不存在，且位于当前仓库根目录的 `Temp/`；工具不会覆盖已有报告、改写 APK/规则/映射、启动构建、连接设备或下载依赖。终端输出聚合字节、符号数量、关键保护结果与可选基准差异；完整 JSON 仅额外保存产物摘要和代码入口名，不输出配置正文、签名材料、地址或用户数据。

测量分别统计根目录 `classes*.dex` 的原始字节、ZIP 压缩字节和实际定义类数，以及 R8 seeds 的类/成员保留根和 mapping 的类名变化。解析 DEX 035–040；未知格式、损坏输入或缺失文件会失败，不能据不完整解析宣布通过。JVM classfile 解析区分类注解与成员注解，从传入引擎 JAR 的真实 `@Keep`/native 声明生成入口要求，再关联 mapping 与 DEX 的定义名称；同时核对反射注册器、应用清单组件和通知模型。传入 `--baseline` 后取当前与历史模型字段、方法的并集；任一方要求固定类名时都保持严格保护，不能用旧基准覆盖当前新增入口。格式不完整的保护要求直接失败。

运行 `python -B scripts/test/apk_r8_report_test.py` 可验证旧基准与新增字段/方法、严格类名要求的组合，以及错误基准的拒绝行为；回归仅使用本仓 `Temp/` 的隔离小夹具，不操作真实APK或触发构建。

退出码 `0` 表示本次名称/定义保护检查通过，`1` 表示保护检查失败，`2` 表示输入、格式或报告写入错误。seeds 不是 DEX 大小或运行频率，mapping 与 APK 的关键入口相符也不能证明它们来自同一完整构建；应保存同轮文件。DEX 字节差异只说明这些产物的体积变化，其他源码/SDK/依赖变化也会影响结果，不能直接归因某条 keep 规则或宣称启动/内存提升。

名称检查不验证所有 JNI 重载描述符、Android 系统权限、ROM 后台限制或 Gson 实际往返。收窄规则后仍须用压缩正式包验收冷启动、全部插件、旧通知缓存恢复、定时/BOOT/时区/休息提醒、应用锁、图片/分享、后台下载与更新安装；涉及设备操作沿用原有授权要求。不能因为静态名称检查通过就删掉旧缓存或跳过真机验收。
