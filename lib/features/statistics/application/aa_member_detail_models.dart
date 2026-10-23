/// 成员账单详情页的入参 / 数据契约。
///
/// 设计意图：分摊详情表的每个成员都可点击进入「该成员作为支出人的账单
/// 详情」。应用查询与页面共享入参和结果模型，页面通过路由参数定位成员。
library;

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';

/// 打开成员账单详情页的入参。
///
/// 只携带定位所需的最小信息（账本 + 参与人），成员名/本人标记随路由参数
/// 一并传入，用于数据加载期间头部即可渲染，不依赖详情数据先就绪。
class AaMemberDetailArgs {
  /// 所属账本 id（UUID，与分摊统计页一致）。
  final String ledgerId;

  /// 参与人标识（账本成员 UUID）。
  final String participantId;

  /// 参与人显示名（真实成员 displayName/account、虚拟用户 name）。
  final String displayName;

  /// 是否本人，用于展示本人头像。
  final bool isSelf;

  const AaMemberDetailArgs({
    required this.ledgerId,
    required this.participantId,
    required this.displayName,
    this.isSelf = false,
  });
}

/// 单笔账单中某参与人的分摊项。
class AaMemberSplit {
  /// 参与人标识（账本成员 UUID）。
  final String participantId;

  /// 参与人显示名。
  final String displayName;

  /// 应摊金额（账本本位币，元，展示口径）。
  final double amount;

  /// 是否本人，用于展示本人头像。
  final bool isSelf;

  const AaMemberSplit({
    required this.participantId,
    required this.displayName,
    required this.amount,
    this.isSelf = false,
  });
}

/// 成员账单详情中的单笔支出（该成员作为支出人，含不分摊）。
class AaMemberBill {
  /// 交易本体（取分类/备注/时间等展示字段）。
  final TransactionDisplay tx;

  /// 交易分类（用于图标与分类名展示，与首页列表同源）。
  final CategoryDisplay? category;

  /// 分摊方式（人均 / 指定金额 / 不分摊），UI 据此渲染方式徽标。
  final AaMode mode;

  /// 账单实付金额（账本本位币，元）。
  final double totalAmount;

  /// 该成员在本笔账单中的支出金额（账本本位币，元）。
  /// 人均/指定金额为应摊值；不分摊或分摊数据异常时整笔归本人。
  final double myShare;

  /// 支出人显示名（本页按支出人维度汇总，通常即成员本人）。
  final String payerName;

  /// 分摊明细（参与人 → 应摊金额）；不分摊账单为空（无分摊明细）。
  final List<AaMemberSplit> splits;

  const AaMemberBill({
    required this.tx,
    this.category,
    required this.mode,
    required this.totalAmount,
    required this.myShare,
    required this.payerName,
    required this.splits,
  });
}

/// 成员账单详情页数据源（该成员全部支出明细，按支出人筛选）。
class AaMemberDetailData {
  /// 账本名（头部副标题）。
  final String ledgerName;

  /// 成员汇总（实付/应摊/净额），与分摊详情表口径一致。
  final AaParticipantSummary member;

  /// 该成员作为支出人的全部支出列表（含不分摊，按时间倒序）。
  final List<AaMemberBill> bills;

  /// 总付：全部账单合计（含不分摊支出），与汇总卡「总付」口径一致。
  double get totalBillAmount =>
      bills.fold<double>(0, (sum, bill) => sum + bill.totalAmount);

  const AaMemberDetailData({
    required this.ledgerName,
    required this.member,
    required this.bills,
  });
}
