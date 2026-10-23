/// AA 分摊编辑页(AaEditPage)的入参 / 回传契约与参与人选项模型。
///
/// 设计意图:AaEditPage 是纯选择器(不写库)。编辑器(widgets 层)
/// 跳转前构造 [AaEditPageArgs],页面 pop 时返回 [AaEditResult],由编辑器
/// 一次性落库。共享模型供应用查询、交易编辑器和分摊页共同使用。
library;

import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';

/// 参与人选项(真实成员或虚拟用户)。
///
/// [id] 为账本成员 UUID，注册成员与占位成员使用同一种身份。
class AaParticipantOption {
  /// 账本成员 UUID。
  final String id;

  /// 显示名(真实成员取 displayName/account,虚拟用户取 name)。
  final String name;

  /// 是否虚拟用户。
  final bool isVirtual;

  /// 是否本人(当前用户)，用于展示本人头像与解析默认支出人。
  final bool isSelf;

  const AaParticipantOption({
    required this.id,
    required this.name,
    required this.isVirtual,
    this.isSelf = false,
  });
}

/// 打开 AaEditPage 的入参(主体信息只读展示 + 分摊编辑初值)。
class AaEditPageArgs {
  /// 所属账本 id(用于查询参与人与虚拟用户)。
  final String ledgerId;

  /// 交易金额(交易币种口径,只读展示)。
  final String amount;

  /// 交易币种代码(只读展示);null 时由页面回退账本本位币。
  final String? currencyCode;

  /// 分类显示名(只读展示)。
  final String categoryName;

  /// 分类 Lucide 图标名(只读展示,供主体卡顶部 icon 解析);空时用兜底图标。
  final String? categoryIconName;

  /// 交易发生时间(只读展示)。
  final DateTime date;

  /// 分摊方式初值(新建默认人均;编辑回填交易当前值)。
  final AaMode mode;

  /// 支出人初值(参与人标识;全局交易字段,非 AA 专属)。
  /// null = 未手动选择:新建默认创建人(落库层回填操作者),编辑保持原值。
  final String? paidByUserId;

  /// 参与人初值;null = 全部成员(运行时展开,不落具体名单)。
  final List<String>? participantIds;

  /// 指定分摊金额初值(key=参与人标识,value=金额字符串);null = 未填写。
  final Map<String, String>? splits;

  const AaEditPageArgs({
    required this.ledgerId,
    required this.amount,
    required this.currencyCode,
    required this.categoryName,
    this.categoryIconName,
    required this.date,
    required this.mode,
    this.paidByUserId,
    this.participantIds,
    this.splits,
  });
}

/// AaEditPage pop 回传的结果;pop null 视为取消(编辑器保持开启、不落库)。
class AaEditResult {
  /// 支出人的账本成员 UUID，属于全局交易字段。
  /// null = 未手动选择:新建由落库层回填操作者(默认支出人 = 创建人),
  /// 编辑不更新保持原值;非 null = 用户手选/编辑回填,恒写该值。
  final String? paidByUserId;

  /// 分摊方式数据库列值:0=人均,2=指定(与 Transactions.aaMode 对齐)。
  final int aaMode;

  /// 参与人标识列表;null = 全部成员(运行时展开)。
  final List<String>? aaParticipants;

  /// 指定分摊金额(key=参与人标识,value=金额字符串);人均模式为 null。
  final Map<String, String>? aaSplits;

  const AaEditResult({
    required this.paidByUserId,
    required this.aaMode,
    required this.aaParticipants,
    required this.aaSplits,
  });
}
