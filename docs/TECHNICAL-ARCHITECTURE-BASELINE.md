# Sesame Notes 技术架构基线

> 基线版本：1.0  
> 生效日期：2026-08-22  
> 适用仓库：sesame-notes（服务端、共享契约、部署）与 sesame-notes-mobile（Flutter 客户端）  
> 文档状态：当前有效，替代散落的架构规范与阶段性说明

## 架构速览

整体运行结构可以压缩为：

```text
                    ┌──────────────────────┐
                    │ React Web / Admin    │
                    │ （规划，尚未交付）   │
                    └──────────┬───────────┘
                               │ OpenAPI / HTTPS
                               ▼
Flutter App ── OpenAPI / HTTPS ──► Fastify API ── Prisma ──► PostgreSQL 17
     ▲                                │
     └──── WebSocket 同步提示 ────────┘
```

Flutter 不是只在联网时工作的普通客户端，而是离线优先应用：

```text
Flutter UI
    ↓
Riverpod
    ↓
Repository
    ↓
Drift / SQLite ←→ Sync Engine ←→ OpenAPI Client ←→ Fastify API
```

PostgreSQL 是服务端权威数据库；每台手机也保存可离线工作的完整业务副本，并在联网后通过同步引擎收敛。WebSocket 只提示客户端执行 pull，不承载最终状态。

## 技术栈先决约束（先读）

严格遵守以下项目技术栈约束，所有代码、方案和建议均不得偏离当前架构决策；未显式选择的项使用本文标记为 [D] 的推荐默认值。

- 服务端：TypeScript 6 strict、Node.js 24 LTS、Fastify 5、TypeBox、Prisma 6、PostgreSQL 17。
- 移动端：Dart 3.12、Flutter 3.44、Riverpod 3、go_router、Dio、Drift/SQLite。
- 跨仓库契约：OpenAPI 3.0.3 Artifact 与生成客户端；不得复制 DTO 或手改生成代码。
- Web/Admin：当前尚未交付；需要实施时默认 React 19、Vite、React Router、TanStack Query、shadcn/ui 与 Tailwind CSS。
- 工程化：主仓库只使用 pnpm workspace；TypeScript 使用 ESLint/Prettier，Dart 使用 dart format/flutter analyze，CI 使用 GitHub Actions。

## 1. 使用与维护规则

本文件是开发者和 Agent 实施代码、方案、测试与评审时必须先读取的技术架构基线。未显式选择的实现采用本文的推荐默认值，不得以个人偏好替换现有架构。

两个项目是独立 Git 仓库，但共同组成一个产品：

- sesame-notes：Fastify API、PostgreSQL 数据模型、OpenAPI 契约、TypeScript 客户端和部署。
- sesame-notes-mobile：Flutter 应用、本地 Drift 数据库、离线优先同步和备份适配器。

本文件必须同时存在于两个仓库的 docs/TECHNICAL-ARCHITECTURE-BASELINE.md，且正文保持逐字一致。任何涉及架构、协议、数据模型、依赖方向、技术栈或质量门禁的变更，都必须在同一个任务中：

1. 检查两个仓库的最新代码、锁文件、迁移、契约与 CI。
2. 更新实现、测试、OpenAPI 或迁移。
3. 同步更新两个仓库中的本文件。
4. 比较两份文件的 SHA-256，确认完全一致。
5. 分别提交两个仓库；不得只更新一方后宣称架构变更完成。

本文件的双仓一致性由开发者手动维护：改动正文时必须同步更新两份 checkout 并逐字比对。

每个仓库只维护 `docs/TECHNICAL-ARCHITECTURE-BASELINE.md` 这一份基线。README 和其他文档只链接本文件，不复制架构规则；知识库不保存基线镜像。

若文档与实现不一致，以已发布契约和可运行代码揭示问题，但必须在本次变更中消除不一致；不得长期保留“文档架构”和“实际架构”两套事实。

## 2. 规则等级

本文使用三个等级，避免把原则、决定和偏好混为一谈：

- [I] Invariant，业务或安全不变量：任何实现都不得违反。
- [A] Architecture Decision，架构决策：变更必须有 ADR、迁移或兼容方案、双仓库影响分析和本文件同步。
- [D] Default，推荐默认值：尚无实现或没有更强约束时采用；替换时需说明收益并通过既有门禁。

优先级为 [I] 高于 [A] 高于 [D]。版本号本身不是理由；只为“更新”而迁移不构成有效收益。

## 3. 技术栈约束

### 3.1 语言与运行时

- [A] 服务端与共享包：TypeScript 6，strict mode，Node.js 24 LTS，ESM。
- [A] 包管理器：pnpm 10；禁止使用 npm 或 yarn 安装依赖，只提交 pnpm-lock.yaml。
- [A] 工作区：pnpm workspaces；主仓库的应用和共享包必须继续由 workspace 管理。
- [A] 移动端：Dart 3.12、Flutter 3.44 stable。
- [I] TypeScript 不得关闭 strict 或 noUncheckedIndexedAccess；不得新增 TypeScript 6 已废弃编译选项。
- [I] 不得手工修改生成的 OpenAPI 客户端代码。

### 3.2 服务端

- [A] 框架：Fastify 5，不切换 Express。
- [A] 形态：模块化单体，按 auth、admin、accounting、sharing、sync、imports、realtime 等业务模块组织。
- [A] 数据库：PostgreSQL 17，生产与 CI 跟踪经过验证的最新 17.x 安全补丁。
- [A] ORM 与迁移：Prisma 6；数据库结构变更必须生成、评审并测试迁移。
- [A] 契约：TypeBox 路由 Schema 生成 OpenAPI 3.0.3，OpenAPI 是跨仓库唯一 HTTP 契约。
- [A] 身份认证：短期 Access Token + 轮换 Refresh Token。
- [A] API 运行时和数据库容器化；TLS 终止与反向代理由宿主机统一管理（如宿主机 Caddy），单服务器编排为 API + PostgreSQL。
- [D] 只有在 Fastify、TypeBox、TypeScript 和 Dart 生成链通过固定兼容样例后，才评估 OpenAPI 3.1。

### 3.3 Web 前端

Web 与 Admin 当前是规划能力，不得描述成已交付运行时。

- [D] 语言：TypeScript strict + HTML + CSS。
- [D] 框架：React 19，Vite 7，CSR SPA。
- [D] 路由：React Router。
- [D] 服务端状态：TanStack Query；局部 UI 状态优先 React 原生能力，确有跨页面客户端状态时再引入 Zustand。
- [D] UI：shadcn/ui + Tailwind CSS + CSS 变量；图标使用 Lucide。
- [D] 表单：React Hook Form + Zod。
- [A] HTTP 调用使用 OpenAPI 生成客户端统一封装鉴权、错误和取消；不得另建一套手写 DTO。
- [I] 颜色、字体、字号、间距、圆角优先使用项目 Design Token，不得在业务组件散落魔法值。

### 3.4 移动端

- [A] UI：Flutter Material。
- [A] 状态与依赖注入：Riverpod 3。
- [A] 路由：go_router。
- [A] HTTP：OpenAPI 生成的 dart-dio 客户端；Dio 负责传输、拦截、取消和错误映射。
- [A] 本地数据库：Drift + SQLite；离线数据先落本地数据库。
- [A] 安全存储：平台 Keychain/Keystore 能力，由现有安全存储适配层访问。
- [I] lib/ 业务代码不得直接依赖具体备份 adapter 包，只能依赖备份核心协议；adapter 包公共入口只暴露 `register*Backend()`，主工程不得 import adapter 的 `src/` 内部实现。

### 3.5 工程化与依赖

- [A] TypeScript 使用 ESLint 与 Prettier；Dart 使用 dart format 与 flutter analyze。
- [A] Git 提交遵循 Conventional Commits。
- [A] 文件和目录默认 kebab-case；组件和类型 PascalCase；变量、函数和方法 camelCase；常量和环境变量 UPPER_SNAKE_CASE；数据库表和字段 snake_case。
- [I] 信任边界必须校验输入并返回稳定、友好的错误模型；可能失败的外部调用要捕获已知异常、记录包含上下文的错误日志，不得泄漏令牌、密码、恢复短语或明文备份密钥。
- [D] 优先标准库、平台能力和已安装依赖；只需要少量函数时不得引入重量级库。
- [A] 公共 TypeScript API 使用 JSDoc；Dart 公共接口和复杂逻辑使用中文文档注释，说明设计原因。
- [A] 临时文件只放各仓库根目录 Temp，并在任务结束前清理。

## 4. 总体拓扑与依赖方向

运行拓扑见头部“架构速览”；本节只定义依赖方向。

- [A] 主仓库依赖方向：apps/api 可依赖 packages/api-contract 和 packages/api-client 的公开入口；业务模块不得反向依赖应用层。
- [A] 服务端模块内部保持 route/controller → service/use-case → repository/Prisma 的单向调用；跨模块只使用公开服务或共享核心能力。
- [D] 上述分层是依赖方向，不要求为简单流程制造只透传调用的 Controller、Service 或 Repository 空壳；能在现有模块内清楚表达时不新增抽象。
- [A] 移动端采用 vertical slice：UI/Provider → Repository/Use Case → Drift 或生成 API Client。
- [I] 数据层、生成客户端和 adapter 不得反向依赖 feature UI。
- [A] 依赖图默认不得新增 SCC；确有业务理由的最小例外必须在本文档说明原因，扩大例外需 ADR。
- [A] 目录级依赖图豁免 `lib/data/` 门面虚拟组：`data/models.dart` 作为唯一出口 re-export 子模型，而 `data/models/` 下 `category_node.dart`、`category_picker_tree.dart`、`ledger_kind.dart` 反向依赖 `data/db.dart`（Drift schema），在目录粒度构成伪环；文件级依赖图无环且无运行风险，该分组默认豁免，不计入 SCC。
- [A] 移动端 UI 只消费 data 层经 `data/models.dart` 出口的展示模型，不得直接 import Drift 生成的 Row 类型；Row 到展示模型的映射由 Provider 或 data 层承担。
- [A] 需要 `BuildContext` / `AppLocalizations` 的格式化放 `shared/presentation`；`lib/utils` 保持纯 Dart 叶子，只做 key 与数值转换。
- [I] WebSocket 只触发 pull；最终状态以带游标的 HTTPS 同步结果为准。
- [I] 备份恢复与业务同步是两条独立链路，恢复不得隐式覆盖云端账本。

## 5. 身份与成员模型

- [A] user_id 是账户身份，来自服务端认证。
- [A] member_id 是账本内身份；交易创建者、编辑者、付款人和分摊人统一引用 member_id。
- [A] 注册用户成员 ID 固定为 `UUIDv5(namespace=ledger_id, name="user:" + lower(user_id))`：`ledger_id` 按去除连字符后的 16 字节 UUID 作为 namespace，name 按 UTF-8 编码；只对 `user_id` 做小写转换，不得额外 trim、改前缀或做其他规范化。
- [I] 服务端与移动端必须共享固定黄金向量；例如 ledger `11111111-1111-4111-8111-111111111111` 与 user `aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa` 必须得到 `056cf10d-2d59-599c-9d97-6749e866aa52`。
- [A] 未注册参与人以 PLACEHOLDER 账本成员表达，可在后续绑定账户（认领）；绑定不能改变历史交易的成员语义。不存在独立的虚拟用户实体或表。
- [I] 交易与分摊的同步/事件/快照只引用 member_id；wire 上不存在 user_id / virtual_user_id 兼容字段。
- [A] 占位成员资料经成员同步实体（payload 仅 display_name，delete 置 REMOVED）；sync/full 下发账本全量 members（含 status），客户端以 LedgerMembers 单表承载 LOCAL/REGISTERED/PLACEHOLDER。
- [I] 接受、退出、移除与认领必须在成员写事务内追加权威 member 事件；注册成员事件携带 member_type/status 完整状态并定向其账号，确保撤权后其他设备仍可 pull 最终状态。认领改写成员引用时，每笔受影响交易只递增一次 revision，并追加权威 transaction 事件。
- [I] 任何受保护 API 的当前用户都只能由服务端验证后的认证上下文决定，客户端提交的用户 ID 不能成为授权依据。
- [I] 成员权限必须在服务端校验，移动端隐藏按钮不能替代授权。

## 6. 金额与分摊语义

### 6.1 精度

- [I] 金额、汇率和分摊不得使用 binary float 参与持久化或业务计算。
- [A] 服务端 amount、native_amount 和 split amount 使用 Decimal(38,10)。
- [A] 汇率使用 Decimal(38,18)。
- [A] HTTP 金额是规范化十进制字符串：最多 28 位整数和 10 位小数，不接受指数形式、负零或多余格式。
- [A] 移动端使用现有 DecimalMoney/十进制字符串能力；数据库保存规范化字符串。
- [I] 派生金额按 ROUND_HALF_EVEN 舍入到 10 位小数；两端黄金测试必须覆盖临界值。
- [A] 当前录入和常规展示以 2 位小数为产品规则，但持久化与传输保留 10 位能力。扩展非 2 位最小货币单位时必须先做 ADR 和全链路测试。

### 6.2 AA 分摊

- [I] 等额分摊先转为整数分，向下取整后把全部余数分配给付款人；例如 10.00 三人分且第三人为付款人，结果为 3.33、3.33、3.34。
- [I] 新数据必须有合法付款人；只允许兼容旧数据时回退到第一位参与者。
- [I] 自定义分摊在移动端编辑/统计边界与服务端写入边界都必须与交易金额精确相等，不使用 0.01 容差或静默改写付款人金额来掩盖计算错误。
- [I] 退款、转账和多币种业务必须复用同一十进制与舍入规则，不得各自实现一套算法。

## 7. 时间语义

- [A] created_at、updated_at、deleted_at、last_edited_at 是机器时间，统一保存 UTC 时间点。
- [A] happened_at 是用户选择的交易发生时间点，通过 API 以 UTC 时间点传输。
- [A] UTC 时间点的 API 表示必须携带时区并规范化为 ISO 8601 `Z`；这些字段表示时间线上的唯一瞬间，不是业务日。
- [A] 当前 v1 的交易业务日是查询时派生值：`business_date_v1 = date(happened_at AT device_timezone)`，不单独持久化。日历和统计均使用该口径；跨时区后分组可能变化，这是当前明确限制，不得声称已支持稳定 business date。
- [I] 不得把无时区日期字符串静默解释成服务器本地时间。
- [D] 只有产品明确要求“跨时区后仍属于原业务日”时，才新增 business_date 与 IANA timezone_id；届时必须做契约、Prisma、Drift 和历史数据迁移，不能重新解释已有 happened_at。

## 8. 离线优先与同步状态机

同步协议定义为状态机 `M = (S, E, δ, s0)`。`S = B × A × C × W`：绑定状态 `B`、活动状态 `A`、冲突状态 `C`和重连工作流 `W`相互正交，不用一个枚举混合不同事实。`E` 是下表事件，`δ` 同时规定下一状态和必须执行的副作；未定义的转换必须失败关闭，不发起网络请求也不改写时间线。

### 8.1 绑定状态

| 状态          | 持久条件                                                  | 含义                                   |
| ------------- | --------------------------------------------------------- | -------------------------------------- |
| LOCAL         | storage_mode=local，sync_id 为空                          | 仅本地，不自动上传                     |
| CLOUD_UNBOUND | storage_mode=cloud，sync_id 为空                          | 首次上云尚未完成绑定                   |
| CLOUD_BOUND   | storage_mode=cloud，sync_id 有值，binding_status 非 stale | 正常云同步                             |
| STALE_BINDING | binding_status=stale                                      | 服务端时间线已变化，自动同步暂停       |
| GONE          | 重连流程确认远端账本不存在                                | 工作流状态；本地副本保留，等待用户决策 |

`B` 由 `(storage_mode, sync_id, binding_status)` 唯一投影；不符合上表的字段组合是 INVALID，必须失败关闭。移动端的可执行投影为 `lib/sync/ledger_sync_state.dart`，push/pull 必须共用该门禁。`A ∈ {IDLE,
 SYNCING}` 为瞬态；`C ∈ {CLEAN, CONFLICTED}` 由是否存在 OPEN sync_conflict 派生；`W ∈ {PRESENT, GONE}` 由重连结果派生，三者都不重复持久化另一份事实。初始状态 `s0` 由本地是否已有账本决定：新建本地账本为 `(LOCAL, IDLE, CLEAN,
 PRESENT)`，用户选择首次上云为 `(CLOUD_UNBOUND, IDLE, CLEAN, PRESENT)`。

### 8.2 允许的状态转换

| 当前状态/事件                               | 动作                                           | 结果                   |
| ------------------------------------------- | ---------------------------------------------- | ---------------------- |
| LOCAL / 本地写入                            | 仅写 Drift                                     | 保持 LOCAL，不隐式上传 |
| CLOUD_UNBOUND / 首次推送或 full 成功        | 保存服务端 sync_id                             | CLOUD_BOUND            |
| CLOUD_BOUND / 定时、手动或 WebSocket 提示   | push 后 pull                                   | 保持 CLOUD_BOUND       |
| push accepted 或 ignored                    | 标记 mutation 已推送，保存服务端 revision      | 队列继续               |
| push/pull conflict                          | 保留 pending，写 OPEN conflict                 | 当前实体 FIFO 暂停     |
| 解决冲突：保留本地                          | 以最新远端 revision 为 base 重排 mutation      | 重新进入 push          |
| 解决冲突：采用远端                          | 清除该实体 pending，应用远端                   | CLEAN                  |
| pull 返回 410                               | 用同一 sync_id 拉 full，覆盖游标               | CLOUD_BOUND            |
| full 返回 412                               | 先保护本地待推送数据为 Safety Fork，再标 stale | STALE_BINDING          |
| STALE_BINDING / 定时、手动或 WebSocket 提示 | 保留 pending，不发 push，不应用该账本 pull     | 保持 STALE_BINDING     |
| STALE_BINDING / 放弃本地分支                | 清 pending/conflict，拉当前时间线 full         | CLOUD_BOUND            |
| 云端账本重连但远端不存在                    | 保留本地数据，交由用户选择                     | GONE                   |
| 任意云绑定 / 显式 detach                    | 清活跃绑定、队列和游标，保留数据来源记录       | LOCAL                  |

- [I] 同一实体 mutation 按 FIFO，使用 base_revision 做 CAS；不得用 force overwrite 绕过冲突。
- [I] OPEN 冲突实体暂停推送，其他实体可继续同步。
- [I] 412 不得自动丢弃本地 pending 或冲突。
- [I] STALE_BINDING 必须按账本隔离 push/pull；其他正常账本和用户全局实体继续同步。解决 stale 必须通过表中的显式用户决策。
- [I] LOCAL 不得因登录、联网或打开页面自动变成云账本。
- [I] 服务端 generation 改变时必须拒绝旧时间线写入。

## 9. 删除、墓碑与长离线客户端

删除生命周期是 `LIVE → TOMBSTONED → PROPAGATED → RETAINED`。`LIVE → TOMBSTONED` 由显式删除触发；`TOMBSTONED → PROPAGATED` 表示 delete SyncChange 已被游标增量传播，或客户端已通过 full 的存活集合收敛；
`PROPAGATED → RETAINED` 不删除记录，只表示等待未来可证明安全的 GC。当前没有 `GC_ELIGIBLE → PURGED` 转换。

- [A] 同步实体删除使用 tombstone，即写 deleted_at；交易删除同时递增 revision 并产生 delete SyncChange。
- [I] 已删除交易不能被普通 update 复活；恢复必须是显式业务动作并产生新版本语义。
- [A] 增量 pull 传递 delete 事件。
- [A] 服务端 full 是账本范围云副本的权威集合：移动端必须 tombstone 快照中缺失的交易、周期交易与占位成员（成员按下发的全量 members 收敛），同时保留本地未推送实体与 OPEN 冲突分支。
- [I] 分类和汇率是用户全局实体。在协议提供用户全局 full 边界前，不得根据单个账本 full 推断其删除。
- [A] 游标早于保留窗口时服务端返回 410，客户端使用 full 收敛；长离线不能靠永久保存所有增量事件解决。
- [I] 当前不自动物理清理同步墓碑。引入 GC 前必须同时定义保留期、最小有效游标、活跃设备确认和超期设备 full 策略；单独增加定时 DELETE 不可接受。

## 10. API 与跨仓库契约

- [A] TypeBox 路由 Schema 是服务端定义源，生成 OpenAPI Artifact。
- [A] 主仓库归档版本化 Artifact；移动端固定版本与 SHA-256，使用 openapi-generator dart-dio 生成客户端。
- [I] 生成代码不得手工编辑；需要变化时修改服务端 Schema、重新生成、检查破坏性变更，再在移动端更新 Artifact 和客户端。
- [I] operationId 唯一；错误使用统一机器码、友好消息和 request/correlation id。
- [I] 跨仓库 DTO 不得靠复制 TypeScript/Dart 手工维护。
- [A] 契约版本线固定 v1.0.0：无存量客户端，破坏性变更直接修订契约与双端客户端，不升版本号；CI 必须检查生成结果没有漂移。

## 11. 认证、Cookie 与 CSRF

- [A] Access Token 短期有效；Refresh Token 轮换并可服务端撤销。
- [A] 浏览器 Refresh Token 使用 HttpOnly Cookie，生产环境 Secure，默认 SameSite=Strict。
- [A] 浏览器凭据请求只允许配置的 Origin，CORS 显式允许 credentials；Origin 校验是 Cookie 写接口的额外边界。
- [D] 只有跨站部署确实要求 SameSite=None 时才增加显式 CSRF Token；届时必须同时启用 Secure、Origin 校验和 CSRF 测试。
- [A] Flutter 使用响应体/安全存储中的 token，不依赖浏览器 Cookie。
- [I] 日志和错误响应不得包含 token、Cookie、密码、恢复短语或密钥。
- [A] Prisma 兼容模型名 ServerEpoch、表 server_epochs 表示“服务端代际”；架构与新业务代码统一使用 generation 术语。不得只为改名制造数据库迁移。

### 11.1 账号一期：手机号登录凭据、账号数据域与两阶段凭证提交

- [A] 服务端登录凭据是规范化 E.164 手机号（phone_e164，唯一）；users 不存在 account 占位列，登录契约只接受 country_code + phone + 必填 device（含安装级 installation_id）。
- [I] 共享成员/统计响应只暴露 member_id、user_id（仅 REGISTERED 账号域）、sesame_number、display_name、avatar_url、avatar_version 与账本内角色状态；同步 payload/快照只暴露 member_id 系列；account、完整手机号与性别不得出现在共享响应、同步 payload、WebSocket 或客户端成员缓存中。
- [I] 客户端设备标识是安装级 installation_id（数据库非空）；服务端按 (user_id, installation_id) upsert 设备并为每个账号返回独立 device_id，同一安装在不同账号间互不冲突。
- [I] 登录/注册/刷新只产生候选会话，凭证束（user_id + device_id + refresh_token）由账号切换协调器在账号域校验完成后以单个 JSON 原子写入安全存储（两阶段提交）；认证类 401 才清除凭证回未登录，网络/5xx 保留凭证与缓存身份。
- [A] 移动端 Drift 以 scope_account_id（ledgers/categories/exchange_rate_overrides）与 account_id（sync_changes）表达账号数据域：null 只表示本机/待归属旧数据；push 只读取当前账号的 mutation，
无账号的旧 mutation 永不上传；登录只建立会话，不得改写 LOCAL 账本的成员绑定、self_member_id 与历史引用。
- [I] 登出/换账号必须先清理旧账号域云数据（云账本、账号域分类/汇率、该账号 mutation 队列与设备 sync_state），本地账本不属于任何账号，绝不触碰；清理失败保留凭证可重试。

## 12. 备份、恢复与密钥威胁模型

- [A] 备份核心只定义协议与加密格式，Supabase、WebDAV、S3 是可替换 adapter。
- [A] 内容使用随机 DEK 与 AES-256-GCM；密码槽使用 Argon2id，当前参数为 64 MiB、3 次、并行度 1。
- [I] 密码是低熵秘密；KDF 只增加离线猜测成本，不能把弱密码变成高熵密钥。
- [I] 恢复短语必须由系统随机生成，至少 128 bit 熵，不接受用户自选短语。其 KDF 用于统一 key-slot 处理，不是熵来源。
- [I] 设备本地密钥槽不得上传为可跨设备恢复材料。
- [A] 恢复分四步：校验清单、下载并校验密文、解密并验证快照、单事务写入。
- [I] 恢复前三步不得修改 live 数据；第四步失败必须完整回滚。
- [I] 恢复到本地副本后不得自动覆盖云端；用户必须显式选择重新绑定、建立新云时间线或仅保留本地。

## 13. 数据库与迁移

- [A] PostgreSQL 是服务端权威持久层，Drift/SQLite 是移动端离线工作副本。
- [I] 服务端约束能表达的唯一性、外键、非空和检查规则应落数据库，不能只依赖 UI。
- [A] Prisma migration 与 Drift migration 都必须前向可测试；涉及同步字段时必须验证两端行为一致。
- [I] Drift `schemaVersion = 1` 只适用于尚无外部稳定用户的初始阶段；首个公开版本后，每次递增都必须保留从上一已发布版本到当前版本的连续迁移链及升级测试，不得只支持新装数据库。
- [D] PostgreSQL 主版本固定 17；postgres:17-alpine 可跟随 17.x 补丁，但上线前要通过迁移检查。

## 14. 测试与质量门禁

- [A] 行为变更需要测试驱动，或与实现同步提供能够验证需求的自动化测试。
- [I] 认证、权限、金额、同步、备份恢复等关键业务逻辑以及缺陷修复必须先有基于需求的失败用例；线上缺陷先稳定复现，再写最小修复。
- [D] CSS、文案、简单 wiring、配置和构建脚本调整无需制造形式化红测，但必须执行与风险相称的静态检查、构建或行为验证。
- [I] 不得为了通过测试修改正确的需求断言。失败时先诊断是实现错误、测试错误还是环境不可用，并以需求为锚点。
- [I] 实现与测试不得共享同一套未经独立验证的错误假设；金额、ID、同步和加密使用黄金向量或契约样例。
- [A] 认证、权限、金额、同步、备份恢复等高风险逻辑覆盖率目标至少 80%；不设置全仓库 80% 指标，优先风险覆盖率，且覆盖率不能替代边界与失败路径测试。
- [A] 主仓库门禁至少包含 lint、format check、typecheck、build、unit、真实 PostgreSQL integration/E2E、contract check、依赖方向检查和架构基线双仓一致性（权威副本哈希）。
- [A] 移动端门禁至少包含 dart format check、flutter analyze --no-pub、unit/widget、项目身份、API 契约、循环依赖、lib/ 业务代码直连 adapter 扫描（Composition Root main.dart 是注册实现的唯一例外）、各 adapter 包 pub get/analyze/test、架构基线双仓一致性（权威副本哈希），以及全量随机顺序测试。
- [I] 合并前要求 CI 同款全量随机顺序测试 0 错误、静态检查 0 warning。
- [A] 外部服务测试使用明确的测试实例或受控 fake；数据库集成测试使用真实 PostgreSQL 测试实例，不用 mock 证明 SQL 正确。

## 15. 环境、部署与运维

- [A] 服务端环境变量使用大写下划线，根目录 .env 不提交；提供 .env.example。
- [A] Flutter 使用 dev/prod flavor 和编译期配置，不把密钥打进仓库。
- [A] GitHub Actions 执行 Lint、Test、Build、Contract 和架构门禁。
- [A] API 与 PostgreSQL 提供容器化开发/部署方式；健康检查与迁移失败必须阻止错误版本接管流量。
- [D] 用户明确不需要服务端备份恢复功能：不定义 RPO/RTO，不做备份脚本、归档校验与恢复演练；数据持久性由宿主机 PostgreSQL 单实例运维承担。
- [A] 日志结构化并携带 request/correlation id；用户错误友好，内部日志保留根因与堆栈，敏感信息脱敏。

## 16. 架构变更触发器

以下变化必须建立 ADR，并同步两个仓库的本基线：

- 更换 Fastify、Prisma、PostgreSQL、Flutter、Riverpod、Drift 或 OpenAPI 生成链。
- 修改金额精度、舍入、AA 余数、时间或时区语义。
- 修改 sync_id、generation、revision、游标、冲突或 tombstone 协议。
- 增加墓碑物理 GC、跨站 Cookie、OpenAPI 3.1 或新的备份格式。
- 改变主仓库模块边界、移动端依赖方向或 adapter 隔离规则。
- 新增 Web/Admin 运行时并把规划技术栈转为实际技术栈。
- 修改认证令牌策略或恢复覆盖云端的规则。

ADR 至少说明：问题、约束、选择、备选、双仓库影响、兼容/迁移、回滚、测试证据和基线同步结果。

## 17. 开发者与 Agent 开工检查

开始前：

- 阅读两个仓库中本文件并确认内容一致。
- 查看两个仓库 git status，保留用户无关改动。
- 查找现有 helper、token、生成客户端和测试模式，避免重复实现。
- 明确本次规则属于 [I]、[A] 还是 [D]。

完成前：

- 先完成需求红测，再完成最小绿测实现；文档-only 变更执行链接和一致性检查。
- 运行受影响单测与仓库规定的全量门禁。
- 若涉及契约、Schema、migration 或架构，更新两个仓库本文件。
- 比较两份基线 SHA-256。
- 分别提交两个仓库并记录 commit hash、CI/本地测试与 push 结果。
