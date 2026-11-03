import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

typedef RecordHistoryQuery = ({String ledgerId, String recordId});

/// 历史读取使用当前账本归属、同步身份及交易云端版本，不修改任何本机记录。
class RecordHistoryContext {
  const RecordHistoryContext({
    required this.isCloud,
    this.syncId,
    this.revision,
  });
  final bool isCloud;
  final String? syncId;
  final int? revision;
  bool get awaitingUpload => isCloud && (syncId == null || revision == null);
}

/// 云端修订号独立于本机编辑序号，变更内容保持原始字符串和 JSON 值。
class CloudRecordHistoryEntry {
  const CloudRecordHistoryEntry({
    required this.id,
    required this.version,
    required this.createdAt,
    required this.changes,
    this.operatorMemberId,
    this.operatorDisplayName,
  });
  final String id;
  final int version;
  final DateTime createdAt;
  final Object? changes;
  final String? operatorMemberId;
  final String? operatorDisplayName;
}

/// 单页响应只包含服务端确认的历史及下一页位置。
class CloudRecordHistoryPage {
  const CloudRecordHistoryPage(this.items, this.nextCursor);
  final List<CloudRecordHistoryEntry> items;
  final String? nextCursor;
}

typedef CloudRecordHistoryLoader =
    Future<CloudRecordHistoryPage> Function(
      RecordHistoryQuery query,
      String? cursor,
      CancelToken cancelToken,
    );

/// 实际查询前复核交易属于当前可见账本，避免旧页面越过账号边界。
final recordHistoryContextProvider = FutureProvider.autoDispose
    .family<RecordHistoryContext, RecordHistoryQuery>((ref, query) async {
      final account = ref.watch(currentAccountIdProvider);
      final generation = ref.watch(authIdentityGenerationProvider);
      try {
        final ledger = await ref.watch(
          ledgerByIdProvider(query.ledgerId).future,
        );
        final transaction = await ref
            .watch(transactionDataAccessProvider)
            .getTransactionById(query.recordId);
        if (!ref.mounted ||
            account != ref.read(currentAccountIdProvider) ||
            generation != ref.read(authIdentityGenerationProvider) ||
            ledger == null ||
            transaction == null ||
            transaction.ledgerId != query.ledgerId) {
          throw StateError('历史记录所属账本或账号已变化');
        }
        return RecordHistoryContext(
          isCloud: ledger.storageMode == 'cloud',
          syncId: ledger.syncId,
          revision: transaction.serverRevision,
        );
      } catch (error, stack) {
        logger.error(
          'RecordHistory',
          '核对历史记录归属失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });

/// 使用生成客户端读取历史，服务响应不能跨账本或交易混入结果。
final cloudRecordHistoryLoaderProvider = Provider<CloudRecordHistoryLoader>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return (query, cursor, cancelToken) async {
    try {
      final response = await client
          .getTransactionsApi()
          .getTransactionEditHistory(
            ledgerId: query.ledgerId,
            transactionId: query.recordId,
            limit: 50,
            cursor: cursor,
            cancelToken: cancelToken,
          );
      final data = response.data;
      if (data == null) throw const FormatException('编辑历史响应为空');
      final items = <CloudRecordHistoryEntry>[];
      for (final item in data.items) {
        if (item.ledgerId != query.ledgerId ||
            item.transactionId != query.recordId) {
          throw const FormatException('编辑历史响应归属不一致');
        }
        items.add(
          CloudRecordHistoryEntry(
            id: item.id,
            version: item.version,
            createdAt: item.createdAt,
            changes: item.changes?.value,
            operatorMemberId: item.operatorMemberId,
            operatorDisplayName: item.operatorDisplayName,
          ),
        );
      }
      return CloudRecordHistoryPage(List.unmodifiable(items), data.nextCursor);
    } catch (error, stack) {
      logger.error(
        'RecordHistory',
        '读取云端编辑历史失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  };
});

/// 已读取页面和分页错误共同保留，失败不伪装成空历史。
class CloudRecordHistoryState {
  const CloudRecordHistoryState({
    required this.context,
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.pageFailed = false,
  });
  final RecordHistoryContext context;
  final List<CloudRecordHistoryEntry> items;
  final String? nextCursor;
  final bool loadingMore;
  final bool pageFailed;
}

/// 分页状态按交易隔离；身份和账本状态变化会结束原请求会话。
final cloudRecordHistoryProvider = AsyncNotifierProvider.autoDispose
    .family<
      CloudRecordHistoryController,
      CloudRecordHistoryState,
      RecordHistoryQuery
    >(CloudRecordHistoryController.new);

class CloudRecordHistoryController
    extends AsyncNotifier<CloudRecordHistoryState> {
  CloudRecordHistoryController(this.query);
  final RecordHistoryQuery query;
  int _epoch = 0;
  CancelToken? _cancelToken;
  CloudRecordHistoryLoader? _load;
  String? _account;
  int? _identityGeneration;
  RecordHistoryContext? _context;
  final Set<String> _seenCursors = {};

  /// 首屏与后续页面共用一份身份快照，令牌刷新不改变身份代次。
  @override
  Future<CloudRecordHistoryState> build() async {
    final epoch = ++_epoch;
    final token = _cancelToken = CancelToken();
    _account = ref.watch(currentAccountIdProvider);
    _identityGeneration = ref.watch(authIdentityGenerationProvider);
    _load = ref.watch(cloudRecordHistoryLoaderProvider);
    _context = null;
    _seenCursors.clear();
    ref.onDispose(() => token.cancel('历史读取会话已结束'));
    try {
      final context = await ref.watch(
        recordHistoryContextProvider(query).future,
      );
      if (!ref.mounted || epoch != _epoch) {
        throw StateError('历史读取会话已变化');
      }
      _context = context;
      _requireCurrent(epoch);
      if (!context.isCloud || context.awaitingUpload) {
        return CloudRecordHistoryState(context: context);
      }
      if (_account == null) throw StateError('请登录后读取云端历史');
      final page = await _load!(query, null, token);
      _requireCurrent(epoch);
      _validatePage(page, const []);
      return CloudRecordHistoryState(
        context: context,
        items: page.items,
        nextCursor: page.nextCursor,
      );
    } catch (error, stack) {
      if (ref.mounted && epoch == _epoch) {
        logger.error(
          'RecordHistory',
          '云端历史首屏未完成',
          safeErrorSummary(error),
          stack,
        );
      }
      rethrow;
    }
  }

  /// 追加成功页；同一页只允许一个请求，失败后保留已有页并提供原位置重试。
  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null || current.nextCursor == null || current.loadingMore) {
      return;
    }
    final epoch = _epoch;
    final cursor = current.nextCursor!;
    state = AsyncData(
      CloudRecordHistoryState(
        context: current.context,
        items: current.items,
        nextCursor: cursor,
        loadingMore: true,
      ),
    );
    try {
      _requireCurrent(epoch);
      final page = await _load!(query, cursor, _cancelToken!);
      _requireCurrent(epoch);
      _validatePage(page, current.items);
      if (page.nextCursor == cursor ||
          page.nextCursor != null && _seenCursors.contains(page.nextCursor)) {
        throw const FormatException('编辑历史分页位置没有前进');
      }
      _seenCursors.add(cursor);
      state = AsyncData(
        CloudRecordHistoryState(
          context: current.context,
          items: List.unmodifiable([...current.items, ...page.items]),
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error, stack) {
      if (!_isCurrent(epoch)) return;
      logger.error(
        'RecordHistory',
        '云端历史下一页未完成',
        safeErrorSummary(error),
        stack,
      );
      state = AsyncData(
        CloudRecordHistoryState(
          context: current.context,
          items: current.items,
          nextCursor: cursor,
          pageFailed: true,
        ),
      );
    }
  }

  /// 账号、同账号重登和账本同步身份切换后，旧结果不得进入当前页面。
  void _requireCurrent(int epoch) {
    if (!_isCurrent(epoch)) {
      throw StateError('历史读取会话已变化');
    }
  }

  /// 当前上下文一旦进入重新校验或换绑状态，分页旧响应即失去发布资格。
  bool _isCurrent(int epoch) {
    if (!ref.mounted ||
        epoch != _epoch ||
        ref.read(currentAccountIdProvider) != _account ||
        ref.read(authIdentityGenerationProvider) != _identityGeneration) {
      return false;
    }
    final context = ref.read(recordHistoryContextProvider(query));
    return !context.isLoading && identical(context.asData?.value, _context);
  }

  /// 云端版本必须严格倒序，重复或错序不能悄悄去重后伪装成完整历史。
  void _validatePage(
    CloudRecordHistoryPage page,
    List<CloudRecordHistoryEntry> previous,
  ) {
    final ids = previous.map((entry) => entry.id).toSet();
    int? version = previous.isEmpty ? null : previous.last.version;
    for (final entry in page.items) {
      if (entry.id.isEmpty ||
          entry.version < 1 ||
          !ids.add(entry.id) ||
          version != null && entry.version >= version) {
        throw const FormatException('编辑历史排序或身份无效');
      }
      version = entry.version;
    }
    if (page.items.isEmpty && page.nextCursor != null) {
      throw const FormatException('空编辑历史页不能继续分页');
    }
  }
}
