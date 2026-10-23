import 'category_conflicts_handler.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/sync/models/ledger_sync_state.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/models/day_book.dart' as day_books;
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'sync_runtime.dart';
import 'accounting_handler.dart';
import 'projection_handler.dart';
import 'payload_handler.dart';
import 'days_handler.dart';
import 'memos_handler.dart';
import 'fitness_handler.dart';
import 'pull_handler.dart';
import 'push_handler.dart';
import 'transfers_handler.dart';
import 'conflicts_handler.dart';
import 'operations_handler.dart';

/// 同步装配的共享依赖及窄协作端口，不引用具体装配实现。
abstract class SyncAssemblyContext {
  final SesameApiClient client;

  final SesameDatabase db;

  final String deviceId;

  /// 测试注入点:默认用生成客户端构造;测试可注入 mock 拦截 HTTP 行为。
  final SyncApi? apiOverride;

  /// 本地状态保护 Fork 的仓储：缺失时仍暂停同步，但不能放弃待保护分支。
  final LocalLedgerRepository? repo;

  /// 日子复用同一同步服务，仓储负责纯定义校验及本地保护原语。
  final DayRepository? dayRepository;

  final MemoRepository? memoRepository;

  /// 在同一协调轮次接入个人健身域；旧业务的独立测试可不启用该域。
  final bool fitnessEnabled;

  /// 读取当前设备 localSelfId（保护 Fork 的"我是谁"决策用）。
  final Future<String> Function()? localSelfIdLoader;

  /// 读取当前登录账号 id；未登录返回 null，云同步操作一律失败关闭。
  final String? Function() currentAccountIdGetter;

  /// 会话代次把同账号退出后重新登录与原会话区分开，防止迟到响应落库。
  final int Function()? sessionGenerationGetter;

  final int? capturedGeneration;

  /// 生产装配注入的待全量下载存储；不依赖同步队列推断快照完整性。
  final CloudLedgerDownloadStore? downloadStore;

  /// 固定创建时的账号代次，迟到响应不能跨会话写入。
  SyncAssemblyContext({
    required this.client,
    required this.db,
    required this.deviceId,
    this.apiOverride,
    this.repo,
    this.dayRepository,
    this.memoRepository,
    this.fitnessEnabled = false,
    this.localSelfIdLoader,
    required this.currentAccountIdGetter,
    this.sessionGenerationGetter,
    this.downloadStore,
  }) : capturedGeneration = sessionGenerationGetter?.call();

  /// 所有处理器共享同一数据库、协议客户端和创建时的账号守卫。
  late final SyncRuntime runtime = SyncRuntime(
    client: client,
    db: db,
    deviceId: deviceId,
    apiOverride: apiOverride,
    currentAccountIdGetter: currentAccountIdGetter,
    sessionGenerationGetter: sessionGenerationGetter,
    generation: capturedGeneration,
  );

  /// accountingHandler 的延迟装配端口。
  AccountingSyncHandler get accountingHandler;

  /// projectionHandler 的延迟装配端口。
  AccountingProjection get projectionHandler;

  /// payloadCodec 的延迟装配端口。
  AccountingPayloadCodec get payloadCodec;

  /// daysHandler 的延迟装配端口。
  DaySyncHandler get daysHandler;

  /// memosHandler 的延迟装配端口。
  MemoSyncHandler get memosHandler;

  /// fitnessHandler 的延迟装配端口。
  FitnessSyncHandler get fitnessHandler;

  /// pullCoordinator 的延迟装配端口。
  SyncPullCoordinator get pullCoordinator;

  /// pushCoordinator 的延迟装配端口。
  SyncPushCoordinator get pushCoordinator;

  /// transferHandler 的延迟装配端口。
  BookTransferHandler get transferHandler;

  /// 默认分类候选与固定身份确认。
  CategoryConflictsHandler get categoryConflicts;

  /// conflictHandler 的延迟装配端口。
  SyncConflictHandler get conflictHandler;

  /// operationsHandler 的延迟装配端口。
  SyncDataOperations get operationsHandler;

  /// 公共同步流程回调，处理器通过端口调用。
  Future<String> transferToLocal(
    SyncTarget target, {
    required bool move,
    String? expectedFullCursor,
  });

  /// 公共同步流程回调，处理器通过端口调用。
  Future<SyncDeletePreview> prepareScopeDelete(SyncTarget target);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> confirmScopeDelete(SyncDeletePreview preview);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> retryRejectedChange(String id);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<String> protectTargetToLocal(SyncTarget target);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> refreshTarget(SyncTarget target);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<day_books.DayBook> copyDayBookToLocal({required String dayBookId});

  /// 公共同步流程回调，处理器通过端口调用。
  Future<day_books.DayBook> moveDayBookToLocal({required String dayBookId});

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> discoverDayBooks();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> discoverMemoBooks();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> discoverFitnessSpaces();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> fullFitnessSpace(String spaceId);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> fullMemoBook({required String memoBookId});

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> fullDayBook({
    required String dayBookId,
    bool refreshPendingDelete = false,
  });

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> accountingFull();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> push();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<({bool deleted})> fetchLedgerRemoteStatus(String ledgerId);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> resolveConflictKeepLocal(String conflictId);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> resolveConflictAdoptRemote(String conflictId);

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> abandonLocalChanges({required String ledgerId});

  /// 公共同步流程回调，处理器通过端口调用。
  Future<int> pull();

  /// 公共同步流程回调，处理器通过端口调用。
  Future<void> full({required String ledgerId});

  /// 公共同步流程回调，处理器通过端口调用。
  Future<LocalStateProtection> localStateProtection(String ledgerId);
}
