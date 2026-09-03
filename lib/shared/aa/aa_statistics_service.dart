import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';
import 'package:sesame_notes/shared/aa/aa_decimal_util.dart';

/// AA 分摊模式枚举。
///
/// 与 [Transactions.aaMode] 列对齐:
/// - [perPerson] (null/0):人均分摊
/// - [noSplit] (1):不分摊,跳过 AA 统计
/// - [custom] (2):指定金额分摊
enum AaMode {
  perPerson,
  noSplit,
  custom;

  /// 从数据库列值(int?)解析为枚举。null/0 → perPerson。
  static AaMode fromDb(int? v) {
    switch (v) {
      case 1:
        return AaMode.noSplit;
      case 2:
        return AaMode.custom;
      default:
        return AaMode.perPerson;
    }
  }
}

/// 单条交易的 AA 分摊结果。
///
/// [sharesDecimal] key=参与人标识(userId 或虚拟用户 syncId),value=应摊金额。
/// 金额口径为账本本位币(由 [nativeAmount] 折算,未折算时回退原币种金额)。
/// 支出人实付与应摊的差额归支出人,保证 sum(应摊) == 实付。
class AaStatisticsTxResult {
  /// 交易 syncId(跨设备标识,本地展示用 tx.id)。
  final String? syncId;

  /// 交易 id（UUID，本地与云端同一标识）。
  final String txId;

  /// 实付金额(账本本位币,单位:元)，业务计算使用 Decimal。
  final Decimal paidAmountDecimal;

  /// 展示层兼容值，不参与业务计算。
  double get paidAmount => toDouble(paidAmountDecimal);

  /// 支出人标识(userId 或虚拟用户 syncId)。
  final String paidBy;

  /// 分摊模式。
  final AaMode mode;

  /// 每人应摊金额(账本本位币,单位:元)。
  final Map<String, Decimal> sharesDecimal;

  /// 展示层兼容值，不参与业务计算。
  Map<String, double> get shares => {
    for (final entry in sharesDecimal.entries) entry.key: toDouble(entry.value),
  };

  AaStatisticsTxResult({
    required this.syncId,
    required this.txId,
    required this.paidAmountDecimal,
    required this.paidBy,
    required this.mode,
    required this.sharesDecimal,
  });
}

/// 单个参与人的 AA 汇总。
class AaParticipantSummary {
  /// 参与人标识(userId 或虚拟用户 syncId)。
  final String participantId;

  /// 参与人显示名(真实用户取 displayName,虚拟用户取 name)。
  final String displayName;

  /// 该参与人总共实付金额(作为支出人)。
  final double totalPaid;

  /// 该参与人总共应摊金额(所有参与交易的分摊合计)。
  final double totalShouldPay;

  /// 是否本人(当前用户);UI 据此追加「(我)」共享后缀。
  final bool isSelf;

  /// 净额 = 实付 - 应摊。正数表示该参与人应收(别人欠他),
  /// 负数表示该参与人应付(他欠别人)。
  double get net => totalPaid - totalShouldPay;

  AaParticipantSummary({
    required this.participantId,
    required this.displayName,
    required this.totalPaid,
    required this.totalShouldPay,
    this.isSelf = false,
  });
}

/// 转账方案(结算建议)。
///
/// 净额>0 的人应收,净额<0 的人应付。本结构表示一笔转账:
/// [from] 应付给 [to] 金额 [amount]。
class AaTransfer {
  final String from;
  final String fromName;

  /// 付款方是否本人;UI 据此追加「(我)」共享后缀。
  final bool fromIsSelf;
  final String to;
  final String toName;

  /// 收款方是否本人;UI 据此追加「(我)」共享后缀。
  final bool toIsSelf;
  final double amount;

  const AaTransfer({
    required this.from,
    required this.fromName,
    this.fromIsSelf = false,
    required this.to,
    required this.toName,
    this.toIsSelf = false,
    required this.amount,
  });
}

/// 账本级 AA 分摊汇总结果。
class AaLedgerStatistics {
  /// 参与人汇总(含真实成员 + 虚拟用户)。
  final List<AaParticipantSummary> participants;

  /// 结算转账方案。
  final List<AaTransfer> transfers;

  AaLedgerStatistics({required this.participants, required this.transfers});
}

/// AA 分摊计算服务(纯计算层,不写库)。
///
/// 入口:账本的全部 AA 交易 + 账本全部参与人(真实成员 + 虚拟用户)。
/// 输出:每人汇总(实付/应摊/净额)+ 转账方案(贪心结算,净额最小化转账笔数)。
///
/// 分摊规则:
/// - 人均(null/0):全部参与人(aaParticipants 空则运行时展开为账本全部成员)
///   均分;每人应摊 = floor(实付×100/n)/100;支出人实付差归支出人。
/// - 不分摊(1):跳过,不进入 AA 统计。
/// - 指定(2):aaSplits 即最终应摊,按分校验 sum == 实付。
///
/// 参与人解析:真实成员取 userId,虚拟用户取 syncId;身份映射由调用方
/// (Provider 层)从 LedgerMembers + LedgerVirtualUsers 组装后传入。
class AaStatisticsService {
  AaStatisticsService._();

  /// 计算单条交易的 AA 分摊结果。
  ///
  /// [tx] 交易行(已过滤 aaMode != noSplit)。
  /// [allParticipants] 账本全部参与人列表(userId 或虚拟用户 syncId),
  ///   人均模式下 aaParticipants 为空时展开为此列表。
  ///
  /// 返回 null 表示该交易无法计算(如指定分摊 aaSplits 解析失败、参与人为空、
  /// 支出人未知)。
  static AaStatisticsTxResult? computeTx({
    required Transaction tx,
    required List<String> allParticipants,
    required ({List<String>? participantIds, Map<String, String>? splits})
    aaModel,
  }) {
    final mode = AaMode.fromDb(tx.aaMode);

    // 账本级汇总统一以「折本位币金额」为计算口径:多币种账本下各笔交易
    // 的实付/应摊才能直接求和,避免 ¥100 + $50 被当成 ¥150。
    // nativeAmount 恒非空（契约），回退原金额兜底。
    final nativeCents = tx.nativeAmount.isEmpty ? tx.amount : tx.nativeAmount;

    // 支出人未知(paidByUserId 为空):实付归属不明,强行归给参与人首个会
    // 造成分摊统计失真(如全算给虚拟用户)。与成员支出模块「未知支出人
    // 无法归属、不计入」口径一致,直接跳过该交易,不参与 AA 统计。
    final paidBy = tx.payerMemberId ?? '';
    if (paidBy.isEmpty) return null;

    // 参与人:指定分摊的关系表行给出具体名单;null/空 → 展开为账本全部成员(运行时展开)。
    final explicitParticipants = aaModel.participantIds;
    final participants =
        (explicitParticipants != null && explicitParticipants.isNotEmpty)
        ? List.of(explicitParticipants)
        : List.of(allParticipants);
    if (participants.isEmpty) return null;

    // 金额为规范化 decimal 字符串，直接解析，不经过 double 归一化。
    final totalDecimal = Decimal.tryParse(nativeCents);
    if (totalDecimal == null || totalDecimal < Decimal.zero) {
      logger.warning('AaStatistics', '交易金额非法 tx=${tx.id} amount=$nativeCents');
      return null;
    }
    final shares = <String, Decimal>{};

    switch (mode) {
      case AaMode.noSplit:
        // 不分摊:理论上调用方已过滤,此处兜底返回 null。
        return null;

      case AaMode.perPerson:
        final payerIndex = participants.indexOf(paidBy);
        // 人均:floor(实付×100/n)/100,支出人实付差归支出人。
        // 支出人不在参与人列表(虚拟用户已删/旧脏数据)时无法把余数
        // 归给支出人,若强行归给第 0 个参与人会扭曲净额,与「支出人
        // 未知」口径一致直接跳过,不参与 AA 统计。
        if (payerIndex < 0) {
          logger.warning(
            'AaStatistics',
            '人均分摊支出人不在参与人列表 tx=${tx.id} paidBy=$paidBy',
          );
          return null;
        }
        final splits = splitEvenly(
          total: totalDecimal,
          participantCount: participants.length,
          payerIndex: payerIndex,
        );
        for (var i = 0; i < participants.length; i++) {
          shares[participants[i]] = splits[i];
        }
        break;

      case AaMode.custom:
        // 指定分摊:关系表行(参与人 → 金额)。
        final customSplits = aaModel.splits;
        if (customSplits == null || customSplits.isEmpty) {
          logger.warning('AaStatistics', '指定分摊 aaSplits 为空 tx=${tx.id}');
          return null;
        }
        {
          final nativeD = Decimal.tryParse(nativeCents);
          final amountD = Decimal.tryParse(tx.amount);
          if (nativeD == null || amountD == null || amountD < Decimal.zero) {
            logger.warning('AaStatistics', '指定分摊交易金额非法 tx=${tx.id}');
            return null;
          }
          final values = <Decimal>[];
          for (final entry in customSplits.entries) {
            final v = Decimal.tryParse(entry.value);
            if (v == null || v < Decimal.zero) {
              logger.warning(
                'AaStatistics',
                '指定分摊金额非法 tx=${tx.id} participant=${entry.key}',
              );
              return null;
            }
            values.add(v);
          }
          // 币种口径归一：分摊行可能存本位币口径（新写入/云端快照）或原币
          // 口径（存量/编辑器直写），用合计匹配判别后统一按本位币参与统计；
          // 换算尾差由支出人（不在分摊列表时最后一位参与人）承接，保证
          // sum(应摊) == 实付（nativeAmount）精确成立。
          final payerIdx = paidBy.isEmpty
              ? -1
              : customSplits.keys.toList().indexOf(paidBy);
          final normalized = normalizeSplitsToNative(
            splits: values,
            amount: amountD,
            nativeAmount: nativeD,
            remainderIndex: payerIdx,
          );
          if (!validateSplitsTotal(total: nativeD, splits: normalized)) {
            logger.warning('AaStatistics', '指定分摊合计不等于交易金额 tx=${tx.id}');
            return null;
          }
          final keys = customSplits.keys.toList();
          for (var i = 0; i < keys.length; i++) {
            shares[keys[i]] = normalized[i];
          }
        }
        break;
    }

    return AaStatisticsTxResult(
      syncId: tx.id,
      txId: tx.id,
      // 实付金额按本位币"元"输出(展示口径)，金额已为 decimal 字符串。
      paidAmountDecimal: totalDecimal,
      paidBy: paidBy,
      mode: mode,
      sharesDecimal: shares,
    );
  }

  /// 计算账本级 AA 分摊汇总。
  ///
  /// [transactions] 账本全部 AA 交易(aaMode != 1,已由 getAaTransactionsByLedger
  ///   过滤)。
  /// [allParticipants] 账本全部参与人标识列表。
  /// [displayNameMap] 参与人标识 → 显示名映射(真实成员取 displayName,
  ///   虚拟用户取 name)。
  /// [selfMap] 参与人标识 → 是否本人(与 [displayNameMap] 同源构建,
  ///   供 UI 层追加「(我)」共享后缀);缺省为空(默认非本人)。
  static AaLedgerStatistics computeLedger({
    required List<Transaction> transactions,
    required List<String> allParticipants,
    required Map<String, String> displayNameMap,
    Map<String, bool> selfMap = const {},

    /// 交易 id → AA 分摊模型(由调用方从关系表读取;缺失时按全部成员人均兜底)。
    Map<String, ({List<String>? participantIds, Map<String, String>? splits})>
        aaByTxId =
        const {},
  }) {
    // 每人汇总全程使用 Decimal，仅最终展示模型转换为 double。
    final paidTotals = <String, Decimal>{};
    final shouldPayTotals = <String, Decimal>{};
    for (final pid in allParticipants) {
      paidTotals[pid] = Decimal.zero;
      shouldPayTotals[pid] = Decimal.zero;
    }

    for (final tx in transactions) {
      final result = computeTx(
        tx: tx,
        allParticipants: allParticipants,
        aaModel: aaByTxId[tx.id] ?? (participantIds: null, splits: null),
      );
      if (result == null) continue;

      // 累加支出人实付
      final payer = result.paidBy;
      paidTotals[payer] =
          (paidTotals[payer] ?? Decimal.zero) + result.paidAmountDecimal;
      shouldPayTotals.putIfAbsent(payer, () => Decimal.zero);

      // 累加每人应摊
      for (final entry in result.sharesDecimal.entries) {
        final pid = entry.key;
        paidTotals.putIfAbsent(pid, () => Decimal.zero);
        shouldPayTotals[pid] =
            (shouldPayTotals[pid] ?? Decimal.zero) + entry.value;
      }
    }

    final participants = paidTotals.keys.map((pid) {
      // 展示名解析不到统一「未知」:真实成员昵称恒非空(注册即分配),
      // 空值只可能来自脏数据,绝不裸显 member id。
      final name = displayNameMap[pid];
      return AaParticipantSummary(
        participantId: pid,
        displayName: (name != null && name.isNotEmpty) ? name : '未知',
        totalPaid: toDouble(paidTotals[pid] ?? Decimal.zero),
        totalShouldPay: toDouble(shouldPayTotals[pid] ?? Decimal.zero),
        isSelf: selfMap[pid] ?? false,
      );
    }).toList();

    final decimalNets = {
      for (final pid in paidTotals.keys)
        pid:
            (paidTotals[pid] ?? Decimal.zero) -
            (shouldPayTotals[pid] ?? Decimal.zero),
    };

    // 生成转账方案:贪心结算,净额最小化转账笔数。
    final transfers = _buildTransfers(participants, decimalNets);

    return AaLedgerStatistics(participants: participants, transfers: transfers);
  }

  /// 贪心结算:净额>0 的人(应收)与净额<0 的人(应付)配对,
  /// 每次取最大应收与最大应付配对,金额取较小者,直至所有净额归零。
  ///
  /// 输出转账方案:[from](应付) → [to](应收) 金额 [amount]。
  static List<AaTransfer> _buildTransfers(
    List<AaParticipantSummary> participants,
    Map<String, Decimal> decimalNets,
  ) {
    // 复制净额,避免修改原始汇总。
    final nets = Map<String, Decimal>.from(decimalNets)
      ..removeWhere((_, value) => value == Decimal.zero);

    final nameOf = <String, String>{
      for (final p in participants) p.participantId: p.displayName,
    };
    // 本人标记映射:与 displayName 同源,供 UI 层追加「(我)」共享后缀。
    final selfOf = <String, bool>{
      for (final p in participants) p.participantId: p.isSelf,
    };

    final result = <AaTransfer>[];
    // 最大迭代次数保护:正常 nets 长度有限,贪心每次至少归零一个,不会死循环。
    var guard = nets.length * 2 + 10;
    while (nets.isNotEmpty && guard-- > 0) {
      // 找最大应付(净额最小,负数)与最大应收(净额最大,正数)。
      String? maxDebtor; // 应付(净额<0)
      String? maxCreditor; // 应收(净额>0)
      for (final entry in nets.entries) {
        if (entry.value < Decimal.zero) {
          if (maxDebtor == null || entry.value < nets[maxDebtor]!) {
            maxDebtor = entry.key;
          }
        } else if (entry.value > Decimal.zero) {
          if (maxCreditor == null || entry.value > nets[maxCreditor]!) {
            maxCreditor = entry.key;
          }
        }
      }
      if (maxDebtor == null || maxCreditor == null) break;

      final debtorNet = nets[maxDebtor]!; // 负数
      final creditorNet = nets[maxCreditor]!; // 正数
      // 转账金额 = min(|debtorNet|, creditorNet)
      final amount = debtorNet.abs() < creditorNet
          ? debtorNet.abs()
          : creditorNet;

      result.add(
        AaTransfer(
          from: maxDebtor,
          fromName: nameOf[maxDebtor] ?? '未知',
          fromIsSelf: selfOf[maxDebtor] ?? false,
          to: maxCreditor,
          toName: nameOf[maxCreditor] ?? '未知',
          toIsSelf: selfOf[maxCreditor] ?? false,
          amount: toDouble(roundHalfEven(amount, scale: 2)),
        ),
      );

      // 更新净额
      final newDebtorNet = debtorNet + amount;
      final newCreditorNet = creditorNet - amount;
      if (newDebtorNet == Decimal.zero) {
        nets.remove(maxDebtor);
      } else {
        nets[maxDebtor] = newDebtorNet;
      }
      if (newCreditorNet == Decimal.zero) {
        nets.remove(maxCreditor);
      } else {
        nets[maxCreditor] = newCreditorNet;
      }
    }
    return result;
  }
}
