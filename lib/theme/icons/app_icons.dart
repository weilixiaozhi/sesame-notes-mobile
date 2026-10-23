import 'package:lucide_icons_flutter/lucide_icons.dart';

/// UI 框架图标：语义化 token。
///
/// 设计意图：Tab/按钮/设置项等"语义固定、不持久化"的图标全部在此定义
/// 一次，调用点只引用 token——换图标只改本文件一行，全仓调用点自动跟随。
/// token 以语义/所在界面命名（而非图标形状），同一图标跨文件复用同一 token。
abstract final class AppIcons {
  static const pin = LucideIcons.pin;
  // 日子固定分类共用现有 Lucide 图标系统。
  static const dayBirthday = LucideIcons.cake;
  static const dayAnniversary = LucideIcons.heart;
  static const dayCountdown = LucideIcons.timer;
  static const dayStage = LucideIcons.calendarRange;
  // ── 导航与通用操作 ──────────────────────────────────────────────
  static const back = LucideIcons.arrowLeft;
  static const chevronLeft = LucideIcons.chevronLeft;
  static const chevronRight = LucideIcons.chevronRight;
  static const chevronDown = LucideIcons.chevronDown;
  static const chevronUp = LucideIcons.chevronUp;
  static const arrowUp = LucideIcons.arrowUp;
  static const arrowDown = LucideIcons.arrowDown;
  static const close = LucideIcons.x;
  static const check = LucideIcons.check;
  // 普通新增入口统一使用圆圈加号。
  static const add = LucideIcons.plusCircle;
  // 业务页独立创建按钮使用无外框加号。
  static const createEntry = LucideIcons.plus;
  static const archive = LucideIcons.archive;
  static const search = LucideIcons.search;
  static const refresh = LucideIcons.refreshCw;
  static const moreVertical = LucideIcons.moreVertical;
  static const delete = LucideIcons.trash2;
  static const clearAll = LucideIcons.listX;
  static const edit = LucideIcons.pencil;
  static const copy = LucideIcons.copy;
  static const share = LucideIcons.share2;
  static const download = LucideIcons.download;
  static const upload = LucideIcons.upload;
  static const sort = LucideIcons.arrowUpDown;
  static const settings = LucideIcons.settings;
  static const cancel = LucideIcons.xCircle;

  // ── 状态/反馈 ───────────────────────────────────────────────────
  static const checkCircle = LucideIcons.checkCircle2;
  static const checkSquare = LucideIcons.checkSquare;
  static const square = LucideIcons.square;
  static const radioUnchecked = LucideIcons.circle;
  static const info = LucideIcons.info;
  static const warning = LucideIcons.alertTriangle;
  static const error = LucideIcons.alertCircle;
  static const visibility = LucideIcons.eye;
  static const lock = LucideIcons.lock;
  static const login = LucideIcons.logIn;
  static const logout = LucideIcons.logOut;
  static const timer = LucideIcons.timer;
  static const restDuration = LucideIcons.timer;
  static const restAlarm = LucideIcons.alarmClock;
  static const clock = LucideIcons.clock;
  static const verified = LucideIcons.badgeCheck;
  static const lightbulb = LucideIcons.lightbulb;

  // ── 云服务/同步 ─────────────────────────────────────────────────
  static const cloud = LucideIcons.cloud;
  static const cloudQueue = LucideIcons.cloudy;
  static const cloudOff = LucideIcons.cloudOff;
  static const cloudDownload = LucideIcons.downloadCloud;
  static const cloudUpload = LucideIcons.uploadCloud;
  static const storage = LucideIcons.database;
  static const backupRestore = LucideIcons.archiveRestore;
  // 云同步状态使用云配置图标。
  static const cloudSync = LucideIcons.cloudCog;
  // 本地存储后端使用硬盘图标。
  static const localStorage = LucideIcons.hardDrive;

  // ── 人/账本/分类 ────────────────────────────────────────────────
  static const person = LucideIcons.user;
  static const people = LucideIcons.users;
  static const split = LucideIcons.split;
  static const personAdd = LucideIcons.userPlus;
  static const personRemove = LucideIcons.userMinus;
  // 昵称/名片编辑入口
  static const nickname = LucideIcons.badge;
  static const book = LucideIcons.bookOpen;
  // 各业务首页统一使用本子管理入口图标。
  static const bookManagement = LucideIcons.notebookText;
  static const category = LucideIcons.shapes;
  static const receipt = LucideIcons.receipt;
  static const money = LucideIcons.banknote;
  static const currencyExchange = LucideIcons.coins;

  // ── 图表/分析 ───────────────────────────────────────────────────
  static const pieChart = LucideIcons.pieChart;
  static const barChart = LucideIcons.barChart3;
  static const autoAwesome = LucideIcons.sparkles;

  // ── 主题/外观 ───────────────────────────────────────────────────
  static const darkMode = LucideIcons.moon;
  static const nightlight = LucideIcons.moonStar;
  static const language = LucideIcons.languages;
  static const notifications = LucideIcons.bell;
  static const sound = LucideIcons.volume2;
  static const vibration = LucideIcons.vibrate;
  static const weight = LucideIcons.weight;

  // ── 文件/数据 ───────────────────────────────────────────────────
  static const folder = LucideIcons.folder;
  static const folderShared = LucideIcons.share2;
  static const fileDownload = LucideIcons.fileDown;
  static const fileUpload = LucideIcons.fileUp;
  static const description = LucideIcons.fileText;
  static const checklist = LucideIcons.listChecks;
  static const driveFileMove = LucideIcons.folderSync;
  static const inbox = LucideIcons.inbox;
  // 数据预览等场景的"预览"区块标识
  static const preview = LucideIcons.eye;
  static const camera = LucideIcons.camera;
  static const qrCode = LucideIcons.qrCode;
  static const link = LucideIcons.link;

  // ── 日历 ────────────────────────────────────────────────────────
  static const calendar = LucideIcons.calendar;
  static const calendarToday = LucideIcons.calendarCheck;
  static const viewWeek = LucideIcons.layoutGrid;

  // ── 安全/锁屏 ───────────────────────────────────────────────────
  static const dialpad = LucideIcons.grid;
  static const fingerprint = LucideIcons.fingerprint;
  static const backspace = LucideIcons.delete;
  static const keyboardReturn = LucideIcons.cornerDownLeft;

  // ── 业务入口──────────────────────────────────
  // 健身：哑铃图标（分类图标库同源字形，语义独立 token）
  static const fitness = LucideIcons.dumbbell;
  static const play = LucideIcons.play;
  static const pause = LucideIcons.pause;
  // 备忘录：文档文本图标（与 description 同字形、不同语义）
  static const memo = LucideIcons.fileText;
  // 富文本工具栏复用应用图标系统，Quill 只负责编辑操作。
  static const undo = LucideIcons.undo;
  static const redo = LucideIcons.redo;
  static const bold = LucideIcons.bold;
  static const orderedList = LucideIcons.listOrdered;
  static const bulletList = LucideIcons.list;
  static const indentIncrease = LucideIcons.indentIncrease;
  static const indentDecrease = LucideIcons.indentDecrease;

  // ── 杂项 ────────────────────────────────────────────────────────
  static const repeat = LucideIcons.calendarSync;

  // ── 分类编辑页 ──────────────────────────────────────────────────
  // 分类详情入口使用竖向柱状图。
  static const categoryDetail = LucideIcons.barChart3;
}
