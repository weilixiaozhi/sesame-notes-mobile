/// AA 分摊 Provider 层。
///
/// 设计意图:
/// - 新增 AA 分摊统计查询、虚拟用户 CRUD 状态入口。
/// - 全部写操作走 [LocalRepository](保证 sync 登记统一,禁止绕过)。
/// - 读操作直接走子仓查询,UI 通过 ref.watch 自动响应数据变化。
///
/// Provider 职责:
/// - [aaEnabledProvider]:账本 AA 开关(读写)。
/// - [ledgerVirtualUsersProvider]:账本虚拟用户列表(Stream)。
/// - 虚拟用户 CRUD 动作函数(createVirtualUser/renameVirtualUser/deleteVirtualUser)。
/// - [aaStatisticsProvider]:账本 AA 分摊汇总(纯计算,依赖交易+成员+虚拟用户)。
library;

import 'dart:ui' as ui;

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' show LedgerMember;
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/features/statistics/application/aa_member_detail_models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';

/// 本地账本自我参与人的展示名:固定本地身份「单机芝麻仔」,
/// 与云昵称无关(本地身份与云身份独立,I-04)。
/// 当前操作者成员 id：统一走 [ledgerIdentityProvider] 的 self member
/// 解析链(self_member_id 权威 → 绑定账号成员 → 本地派生 LOCAL 成员 →
/// 设备身份兜底),与落库层 operatorMemberId 的身份解析口径一致。
///
/// 供分摊编辑页默认支出人展示/锁定使用。身份与登录账号解耦：
/// 登录/退出只改绑定,不改成员 id。
Future<String> authorMemberIdForLedger(WidgetRef ref, String ledgerId) async {
  final identity = await ref.read(ledgerIdentityProvider(ledgerId).future);
  return identity.selfMemberId;
}

/// 账本成员镜像表查询(key = 账本 UUID)。
///
/// 管理与新建交易只展示 ACTIVE 成员；LEFT/REMOVED 由历史汇总单独读取。
final ledgerMembersProvider = FutureProvider.autoDispose
    .family<List<LedgerMember>, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);
      final repo = ref.watch(repositoryProvider);
      try {
        final members = await repo.getMembersByLedger(ledgerId);
        return members.where((member) => member.status == 'ACTIVE').toList();
      } catch (e, st) {
        logger.error('AaStatistics', '读取账本成员失败 ledgerId=$ledgerId', e, st);
        rethrow;
      }
    });

/// 页面使用的活动成员展示列表；底层 Row 仅留在 application 内部。
final ledgerMemberDisplaysProvider = FutureProvider.autoDispose
    .family<List<LedgerMemberDisplay>, String>((ref, ledgerId) async {
      final members = await ref.watch(ledgerMembersProvider(ledgerId).future);
      return members.map((member) => member.toDisplay()).toList();
    });

/// 账本成员展示映射(全量非 tombstone,含 LEFT/REMOVED;key = member id)。
///
/// 供首页交易列表、详情 sheet、编辑器作者位等展示路径解析创建者/编辑者/
/// 支出人昵称:历史交易仍引用已离开成员,必须保留其展示名。
final ledgerMemberDisplayMapProvider = FutureProvider.autoDispose
    .family<Map<String, LedgerMemberDisplay>, String>((ref, ledgerId) async {
      ref.watch(dataChangeSignalProvider);
      final repo = ref.watch(repositoryProvider);
      try {
        final members = await repo.getMembersByLedger(ledgerId);
        return {for (final m in members) m.id: m.toDisplay()};
      } catch (e, st) {
        logger.error('AaStatistics', '读取账本成员展示映射失败 ledgerId=$ledgerId', e, st);
        rethrow;
      }
    });

/// 成员写入后同时刷新 Row 查询缓存与页面展示缓存。
void invalidateLedgerMemberDisplays(WidgetRef ref, String ledgerId) {
  ref.invalidate(ledgerMembersProvider(ledgerId));
  ref.invalidate(ledgerMemberDisplaysProvider(ledgerId));
  ref.invalidate(ledgerMemberDisplayMapProvider(ledgerId));
}

/// 当前账本的 AA 分摊开关(Stream,自动响应 ledger.aaEnabled 变更)。
///
/// UI(账本设置页开关)watch 此 provider 即可实时反映开关状态;
/// 写入走 [setAaEnabled] 动作函数。
final aaEnabledProvider = StreamProvider<bool>((ref) {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  final repo = ref.watch(repositoryProvider);
  return repo.watchLedger(ledgerId).map((l) => l?.aaEnabled ?? false);
});

/// 切换账本 AA 分摊开关(动作函数)。
///
/// 走 [LocalRepository.updateLedger] 保证 changeTracker 登记 sync
/// (aaEnabled 必须跨设备同步)。
Future<void> setAaEnabled(WidgetRef ref, String ledgerId, bool enabled) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.updateLedger(id: ledgerId, aaEnabled: enabled);
    // 失效账本流,确保 UI 立即刷新。
    ref.invalidate(currentLedgerProvider);
  } catch (e, st) {
    logger.error(
      'AaStatistics',
      'setAaEnabled 失败 ledger=$ledgerId enabled=$enabled',
      e,
      st,
    );
    rethrow;
  }
}

/// 账本虚拟用户列表(Stream,自动响应增删改)。
///
/// family by ledgerId,UI(分摊设置/编辑页)watch 此 provider 渲染参与人选项。
/// 账本占位成员列表（原虚拟用户，memberType=PLACEHOLDER）。
/// 保留 provider 名以兼容既有 UI 引用；类型统一为 LedgerMember。
final ledgerVirtualUsersProvider = StreamProvider.autoDispose
    .family<List<LedgerMember>, String>((ref, ledgerId) {
      final repo = ref.watch(repositoryProvider);
      return repo
          .watchMembersByLedger(ledgerId)
          .map(
            (members) => members
                .where(
                  (member) =>
                      member.memberType == 'PLACEHOLDER' &&
                      member.status == 'ACTIVE',
                )
                .toList(),
          );
    });

/// 页面使用的活动占位成员展示列表。
final ledgerVirtualUserDisplaysProvider = Provider.autoDispose
    .family<AsyncValue<List<LedgerMemberDisplay>>, String>((ref, ledgerId) {
      return ref
          .watch(ledgerVirtualUsersProvider(ledgerId))
          .whenData(
            (members) => members
                .map((member) => member.toDisplay())
                .toList(growable: false),
          );
    });

/// 新建虚拟用户(动作函数)。
///
/// 走 [LocalRepository.createVirtualUser] 委托层,保证 changeTracker 登记 sync
/// (虚拟用户是 ledger-scoped 同步实体,change log 走 create)。
/// 失败时抛错由调用方(UI)展示友好提示。
Future<String> createVirtualUser(
  WidgetRef ref, {
  required String ledgerId,
  required String name,
}) async {
  try {
    final repo = ref.read(repositoryProvider);
    return await repo.createPlaceholderMember(ledgerId: ledgerId, name: name);
  } catch (e, st) {
    logger.error('AaStatistics', '新建虚拟用户失败 ledger=$ledgerId name=$name', e, st);
    rethrow;
  }
}

/// 重命名虚拟用户(动作函数)。
Future<void> renameVirtualUser(
  WidgetRef ref, {
  required String id,
  required String name,
}) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.renameMember(id: id, name: name);
  } catch (e, st) {
    logger.error('AaStatistics', '重命名虚拟用户失败 id=$id name=$name', e, st);
    rethrow;
  }
}

/// 删除虚拟用户(动作函数,硬删)。
///
/// 名下有账(被交易 aaParticipants 引用)不可删,
/// 子仓抛 [StateError],调用方(UI)catch 后展示友好提示。
Future<void> deleteVirtualUser(WidgetRef ref, String id) async {
  try {
    final repo = ref.read(repositoryProvider);
    await repo.deleteMember(id);
  } on StateError {
    // 名下有账不可删,向上透传让 UI 展示。
    rethrow;
  } catch (e, st) {
    logger.error('AaStatistics', '删除虚拟用户失败 id=$id', e, st);
    rethrow;
  }
}

/// 按账本归属解析当前操作者 member id。
///
/// 供分摊编辑页默认支出人展示/锁定使用,与落库层 operatorMemberId 的身份
/// 解析口径一致,避免页面直接依赖 TxAuthorService。
Future<String?> currentOperatorIdForLedger(WidgetRef ref, String ledgerId) =>
    authorMemberIdForLedger(ref, ledgerId);

/// 账本 AA 参与人选项列表(真实成员 + 虚拟用户)。
///
/// 供编辑器 AA 区块、AaEditPage、交易详情页统一取参与人名册,
/// 标识口径与 [aaStatisticsProvider] 一致(真实成员 userId、虚拟用户 id)。
/// 展示名与本人标记统一走 [ledgerIdentityProvider],与成员管理/成员支出
/// 模块同一套解析逻辑。
///
/// 单人/本地账本(成员数 = 1)无成员表,此处会把 owner 自动纳入参与人
/// 名册,避免参与人选择器在单人账本场景下出现空列表、用户无从下手。
final aaParticipantOptionsProvider = FutureProvider.autoDispose
    .family<List<AaParticipantOption>, String>((ref, ledgerId) async {
      final identity = await ref.watch(ledgerIdentityProvider(ledgerId).future);
      final options = <AaParticipantOption>[];

      // 真实成员:ACTIVE + 非 PLACEHOLDER(历史 LEFT/REMOVED 不可再选)。
      final realMembers = identity.memberMap.values
          .where((m) => m.memberType != 'PLACEHOLDER' && m.status == 'ACTIVE')
          .toList();
      if (realMembers.isEmpty && identity.selfMemberId.isNotEmpty) {
        // 单人/本地账本无成员表:把 self member 纳入参与人名册,
        // 保证参与人选择器至少有一个可选项。
        options.add(
          AaParticipantOption(
            id: identity.selfMemberId,
            name: identity.displayNameOf(identity.selfMemberId),
            isVirtual: false,
            isSelf: true,
          ),
        );
      } else {
        for (final m in realMembers) {
          options.add(
            AaParticipantOption(
              id: m.id,
              // 展示名与本人标记统一走身份解析链(昵称恒非空,防御兜底「未知」)。
              name: identity.displayNameOf(m.id),
              isVirtual: false,
              isSelf: identity.isSelfOf(m.id),
            ),
          );
        }
      }

      // 占位成员(原虚拟用户):UUID 作为参与人标识(与统计口径一致)。
      for (final vu in identity.memberMap.values.where(
        (m) => m.memberType == 'PLACEHOLDER' && m.status == 'ACTIVE',
      )) {
        options.add(
          AaParticipantOption(
            id: vu.id,
            name: identity.displayNameOf(vu.id),
            isVirtual: true,
          ),
        );
      }
      return options;
    });

/// 账本成员支出统计项(按 paidByUserId 聚合)。
///
/// 设计意图:成员支出模块需要包含虚拟用户的支出,而云端 memberStats 仅含
/// 真实成员。按交易 paidByUserId 本地聚合(支出人 = paidByUserId),
/// 关联参与人名册(真实成员 + 虚拟用户)拿展示名,与 AA 分摊统计口径一致。
class MemberExpenseStatItem {
  const MemberExpenseStatItem({
    required this.participantId,
    required this.displayName,
    required this.expenseTotal,
    required this.txCount,
    this.isSelf = false,
  });

  /// 参与人标识(member id 或虚拟用户 id)。
  final String participantId;

  /// 展示名(统一走身份解析链:真实成员 displayName/云昵称、虚拟用户 name)。
  ///
  /// 本人时已剥离「(我)」后缀(仅保留纯名字),「(我)」标记由 UI 层
  /// 统一渲染,保证与成员管理模块的字号/颜色/空格一致。
  final String displayName;

  /// 该成员作为支出人的支出金额合计(单位:元;源为 Decimal 字符串,直接解析)。
  final double expenseTotal;

  /// 该成员作为支出人的支出笔数。
  final int txCount;

  /// 是否本人(当前用户);UI 据此追加「(我)」后缀,与成员管理模块一致。
  final bool isSelf;
}

/// 账本成员支出统计(按 paidByUserId 聚合,含虚拟用户)。
///
/// 数据源:账本全部支出交易(txType='expense'),按 paidByUserId 分组聚合
/// 金额与笔数;展示名取参与人名册(真实成员 + 虚拟用户),与 AA 分摊统计
/// 口径一致。paidByUserId 为空的交易不计入(支出人未知,无法归属)。
final memberExpenseStatsProvider = FutureProvider.autoDispose
    .family<List<MemberExpenseStatItem>, String>((ref, ledgerId) async {
      // 监听统一数据变更信号:任何交易/成员/虚拟用户写入都会自动重算。
      // 头像版本参与 MemberAvatar 缓存键,换头像后自动重载,无需额外刷新信号。
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(ledgerId);
      if (ledger == null) return const [];

      // 账本全部支出交易(只统计支出,与首页/统计口径一致)。
      final allTx = await repo.getTransactionsByLedger(ledgerId);
      final expenseTx = allTx.where((t) => t.txType == 'expense').toList();

      // 按 paidByUserId 聚合:金额合计 + 笔数。paidByUserId 为空跳过(无法归属)。
      // 金额统一按「折本位币」(nativeAmount) 累加,与 AA 分摊统计口径一致,
      // 多币种账本下不把原币金额直接相加;历史未折算数据回退原金额。
      // 金额为规范化 Decimal 字符串(单位:元),用 Decimal 累加避免浮点误差,
      // 输出时直接 toDouble,无需再 /100。
      final amountMap = <String, Decimal>{};
      final countMap = <String, int>{};
      for (final t in expenseTx) {
        final pid = t.payerMemberId;
        if (pid == null || pid.isEmpty) continue;
        final amt =
            Decimal.tryParse(
              t.nativeAmount.isNotEmpty ? t.nativeAmount : t.amount,
            ) ??
            Decimal.zero;
        amountMap[pid] = (amountMap[pid] ?? Decimal.zero) + amt;
        countMap[pid] = (countMap[pid] ?? 0) + 1;
      }

      // 参与人名册 → 展示名/本人标记:统一走 ledgerIdentityProvider 口径
      // (本地账本 self 固定「单机芝麻仔」,云/共享账本本人显云昵称,
      // 解析不到统一「未知」),历史支出保留 LEFT/REMOVED 成员的展示名。
      final identity = await ref.watch(ledgerIdentityProvider(ledgerId).future);
      final displayNameMap = <String, String>{
        for (final e in identity.memberMap.entries)
          e.key: identity.displayNameOf(e.key),
      };
      final selfMap = <String, bool>{
        for (final e in identity.memberMap.entries)
          e.key: identity.isSelfOf(e.key),
      };
      // self member 即使无成员行也要能解析(历史脏数据兜底)。
      if (identity.selfMemberId.isNotEmpty) {
        displayNameMap.putIfAbsent(
          identity.selfMemberId,
          () => identity.displayNameOf(identity.selfMemberId),
        );
        selfMap[identity.selfMemberId] = true;
      }

      // 组装结果:仅保留有支出的参与人(amountMap 的 key),按金额降序。
      final items = <MemberExpenseStatItem>[];
      amountMap.forEach((pid, total) {
        final isSelf = selfMap[pid] ?? identity.isSelfOf(pid);
        items.add(
          MemberExpenseStatItem(
            participantId: pid,
            // 解析不到统一「未知」,不渲染空名也不裸显 id。
            displayName: displayNameMap[pid] ?? identity.displayNameOf(pid),
            expenseTotal: total.toDouble(),
            txCount: countMap[pid] ?? 0,
            isSelf: isSelf,
          ),
        );
      });
      items.sort((a, b) => b.expenseTotal.compareTo(a.expenseTotal));
      return items;
    });

/// 账本 AA 分摊汇总(纯计算,依赖交易+成员+虚拟用户)。
///
/// watch [dataChangeSignalProvider] 让任意写库(含云同步 pull)后自动重算。
final aaStatisticsProvider = FutureProvider.autoDispose
    .family<AaLedgerStatistics, String>((ref, ledgerId) async {
      // 依赖统一数据变更信号，交易、分摊或成员变化时自动重算。
      ref.watch(dataChangeSignalProvider);

      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(ledgerId);
      if (ledger == null) {
        return AaLedgerStatistics(participants: const [], transfers: const []);
      }

      // 账本未开启 AA:返回空汇总(入口隐藏、历史数据不展示)。
      if (!ledger.aaEnabled) {
        return AaLedgerStatistics(participants: const [], transfers: const []);
      }

      // 1) 取账本全部 AA 交易(aaMode != 1,已过滤"不分摊")
      final aaTxs = await repo.getAaTransactionsByLedger(ledgerId);

      // 2) 取账本全部参与人:展示名与本人标记统一走 ledgerIdentityProvider
      // (本地账本 self 固定「单机芝麻仔」,云/共享账本本人显云昵称,
      // 解析不到统一「未知」),历史汇总保留 LEFT/REMOVED 真实成员,
      // 避免成员退出后旧账金额消失;repository 已统一排除 tombstone。
      final identity = await ref.watch(ledgerIdentityProvider(ledgerId).future);
      final participantIds = <String>[];
      final displayNameMap = <String, String>{};
      final selfMap = <String, bool>{};
      for (final e in identity.memberMap.entries) {
        participantIds.add(e.key);
        displayNameMap[e.key] = identity.displayNameOf(e.key);
        selfMap[e.key] = identity.isSelfOf(e.key);
      }
      // self member 即使无成员行也要纳入名册(单人账本/历史脏数据兜底)。
      if (identity.selfMemberId.isNotEmpty &&
          !displayNameMap.containsKey(identity.selfMemberId)) {
        participantIds.add(identity.selfMemberId);
        displayNameMap[identity.selfMemberId] = identity.displayNameOf(
          identity.selfMemberId,
        );
        selfMap[identity.selfMemberId] = true;
      }

      // 3) 预取指定分摊关系表行,供纯计算服务使用(人均/不分摊不落行)。
      final aaByTxId =
          <
            String,
            ({List<String>? participantIds, Map<String, String>? splits})
          >{};
      for (final tx in aaTxs) {
        aaByTxId[tx.id] = aaRowsToEditModel(
          (await repo.getTransactionSplits(
            tx.id,
          )).map((row) => row.toDisplay()).toList(growable: false),
        );
      }

      // 4) 调用纯计算服务
      return AaStatisticsService.computeLedger(
        transactions: aaTxs,
        allParticipants: participantIds,
        displayNameMap: displayNameMap,
        selfMap: selfMap,
        aaByTxId: aaByTxId,
      );
    });

/// 成员账单详情(按支出人维度汇总)。
///
/// 分摊详情表点击成员进入本详情页:只展示「该成员作为支出人」的 AA 账单
/// (aaMode != 1),并复用 [aaStatisticsProvider] 的参与人名册 / 本人标记 /
/// 汇总口径,保证详情页与分摊详情表的实付 / 应摊 / 差额完全一致。
///
/// 单笔账单的分摊明细由 [AaStatisticsService.computeTx] 重算(与账本级
/// 统计同一条计算路径),避免维护第二套分摊算法。
final aaMemberDetailProvider = FutureProvider.autoDispose
    .family<AaMemberDetailData?, ({String ledgerId, String participantId})>((
      ref,
      args,
    ) async {
      // 依赖账本级统计:成员/交易变化时详情页自动重算,且直接复用其结果中的
      // 参与人名册与本人标记,避免在 Provider 层再复制一份身份组装逻辑。
      final stats = await ref.watch(aaStatisticsProvider(args.ledgerId).future);
      final repo = ref.read(repositoryProvider);
      final ledger = await repo.getLedgerById(args.ledgerId);
      if (ledger == null || !ledger.aaEnabled) return null;

      // 从统计结果中定位成员:统计结果包含全部参与人(含虚拟用户与兜底参与人),
      // 找不到说明该参与人已不在当前账本,直接返回 null 走空态兜底。
      AaParticipantSummary? member;
      for (final p in stats.participants) {
        if (p.participantId == args.participantId) {
          member = p;
          break;
        }
      }
      if (member == null) return null;

      // 参与人名册 / 显示名 / 本人标记均以统计结果为唯一来源,与分摊详情表一致。
      final participantIds = <String>[
        for (final p in stats.participants) p.participantId,
      ];
      final nameOf = <String, String>{
        for (final p in stats.participants) p.participantId: p.displayName,
      };
      final selfOf = <String, bool>{
        for (final p in stats.participants) p.participantId: p.isSelf,
      };

      // 取账本全部交易(带分类);watch 变体返回流,取首帧快照即可。
      // 成员详情本质是「首页支出列表按支出人筛选」:全部支出(含不分摊)
      // 都要展示,仅收入交易与未知支出人不归属任何成员。
      final all = await repo
          .watchTransactionsWithCategoryAll(ledgerId: args.ledgerId)
          .first;
      // 解析不到的展示名统一「未知」,绝不裸显 member id。
      final l10n = lookupAppLocalizations(
        ref.read(languageProvider) ?? ui.PlatformDispatcher.instance.locale,
      );
      String nameOrUnknown(String? id) {
        if (id == null) return l10n.aaUnknownUser;
        final name = nameOf[id];
        return (name != null && name.isNotEmpty) ? name : l10n.aaUnknownUser;
      }

      final bills = <AaMemberBill>[];
      for (final it in all) {
        final tx = it.t;
        if (tx.txType != 'expense') continue; // 支出明细不含收入交易。
        final paidBy = tx.payerMemberId;
        if (paidBy == null || paidBy.isEmpty) continue; // 支出人未知,无法归属。
        if (paidBy != args.participantId) continue; // 只保留本人垫付的账单。

        final mode = AaMode.fromDb(tx.aaMode);
        // 不分摊(aaMode=1)不参与 AA 计算:整笔支出归本人,无分摊明细;
        // 指定分摊数据异常(如 aaSplits 为空)同样降级为整笔归本人。
        final result = mode == AaMode.noSplit
            ? null
            : AaStatisticsService.computeTx(
                tx: tx,
                allParticipants: participantIds,
                aaModel: aaRowsToEditModel(
                  (await repo.getTransactionSplits(
                    tx.id,
                  )).map((row) => row.toDisplay()).toList(growable: false),
                ),
              );
        if (result == null) {
          // 金额为 Decimal 字符串(单位:元),直接解析;解析失败兜底 0。
          final txTotal =
              Decimal.tryParse(
                tx.nativeAmount.isNotEmpty ? tx.nativeAmount : tx.amount,
              )?.toDouble() ??
              0;
          bills.add(
            AaMemberBill(
              tx: tx.toDisplay(),
              category: it.category?.toDisplay(),
              mode: mode,
              // 成员详情按账本本位币口径展示,与分摊详情表/汇总卡一致。
              totalAmount: txTotal,
              myShare: txTotal,
              payerName: nameOrUnknown(paidBy),
              splits: const [],
            ),
          );
          continue;
        }

        final shares = result.shares;
        bills.add(
          AaMemberBill(
            tx: tx.toDisplay(),
            category: it.category?.toDisplay(),
            mode: result.mode,
            totalAmount: result.paidAmount,
            // 本人应摊:人均模式全员在册;指定金额未填本人时兜底 0。
            myShare: shares[args.participantId] ?? 0,
            payerName: nameOrUnknown(result.paidBy),
            splits: [
              for (final e in shares.entries)
                AaMemberSplit(
                  participantId: e.key,
                  displayName: nameOrUnknown(e.key),
                  amount: e.value,
                  isSelf: selfOf[e.key] ?? false,
                ),
            ],
          ),
        );
      }
      // 按发生时间倒序,列表按日期分组时自然保持最新在前。
      bills.sort((a, b) => b.tx.happenedAt.compareTo(a.tx.happenedAt));

      return AaMemberDetailData(
        ledgerName: ledger.name,
        member: member,
        bills: bills,
      );
    });
