/// debug 包验收数据一键生成服务。
///
/// 仅由首页 debug 入口（kDebugMode）调用。所有写入复用 [LocalRepository]
/// 真实写路径（变更登记 / 汇率折算 / 分摊归一化）：云端账本填充的数据会
/// 登记 sync_changes 由同步服务推送，本地账本不进同步通道。
library;

import 'dart:math';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart'
    show TransactionSplitInput;

/// 验收数据填充器。
///
/// 设计要点：
/// - 账单金额/日期随机，但币种按固定序列轮换（保证多币种覆盖是稳定事实
///   而非概率事件）、AA 分摊按固定节奏分布（每 4 笔 1 笔人均），便于验收
///   断言与统计页各周期均有数据；
/// - 指定分摊账单固定为本位币、金额精确合计，避免命中分摊归一化的脏值兜底；
/// - 支出人从账本活跃成员轮换，模拟真实创建行为，成员支出统计不失真。
class AcceptanceDataSeeder {
  AcceptanceDataSeeder(this.repo);

  final LocalRepository repo;

  final Random _rand = Random();

  /// 填充账单的币种轮换序列：本位币打头，任何一批填充都同时出现本币与外币。
  static const List<String> _currencies = [
    'CNY',
    'USD',
    'JPY',
    'EUR',
    'GBP',
    'HKD',
  ];

  int _currencyIndex = 0;

  /// 虚拟用户名池（验收专用）。
  static const List<String> _virtualUserNames = ['小美', '阿强', '老王'];

  /// 短后缀：允许重复点击生成不同名实体，避免同名歧义。
  static String suffix() => '${DateTime.now().millisecondsSinceEpoch % 10000}';

  /// 一键填充当前账本账单：近 12 个月（含当月），每月 6~8 笔支出。
  ///
  /// - 当月前两笔固定落在今天，保证「今日/本周」统计有数据；
  /// - 币种按固定序列轮换，稳定覆盖多币种统计路径；
  /// - 支出人从账本活跃成员轮换，每 4 笔固定 1 笔人均 AA 分摊；
  /// - 分类取账本可用支出分类，为空时自建「验收填充」兜底分类。
  Future<int> fillBills({
    required String ledgerId,
    String? operatorMemberId,
  }) async {
    final members = await _activeMembers(ledgerId);
    final catIds = await _expenseCategoryIds();
    final now = DateTime.now();
    var count = 0;
    for (var m = 0; m < 12; m++) {
      final monthStart = DateTime(now.year, now.month - m, 1);
      final daysInMonth = DateTime(
        monthStart.year,
        monthStart.month + 1,
        1,
      ).difference(monthStart).inDays;
      // 当月账单不落未来日期；其余月份整月分布。
      final maxDay = m == 0 ? now.day : daysInMonth;
      final perMonth = 6 + _rand.nextInt(3);
      for (var i = 0; i < perMonth; i++) {
        // 当月前两笔固定今天，保证今日/本周统计非空。
        final day = (m == 0 && i < 2) ? now.day : 1 + _rand.nextInt(maxDay);
        final payer = members.isEmpty
            ? null
            : members[_rand.nextInt(members.length)].id;
        // 每 4 笔固定 1 笔人均分摊：成员 >= 2 且支出人存在时才开 AA。
        final aaMode = (count % 4 == 0 && payer != null && members.length >= 2)
            ? 0
            : null;
        await repo.addTransaction(
          ledgerId: ledgerId,
          type: 'expense',
          amount: _randomAmount(),
          categoryId: catIds[_rand.nextInt(catIds.length)],
          happenedAt: DateTime(
            monthStart.year,
            monthStart.month,
            day,
            _rand.nextInt(24),
            _rand.nextInt(60),
          ),
          note: '验收填充',
          // 显式传币种：聚合层按账本本位币补 nativeAmount 快照（无汇率时
          // 退化为原币金额，由未折算检测捞回，与真实记账路径一致）。
          currencyCode: _currencies[_currencyIndex++ % _currencies.length],
          payerMemberId: payer,
          aaMode: aaMode,
          operatorMemberId: operatorMemberId,
        );
        count++;
      }
    }
    return count;
  }

  /// 新建三种 AA 分摊账单：人均 / 指定金额 / 不分摊 各一笔。
  ///
  /// 全部为本位币账单（native == amount），指定分摊金额精确合计，
  /// 保证分摊统计 sum(应摊) == 实付 精确成立。参与人不足两人时自动
  /// 补建虚拟用户，保证人均/指定分摊有真实对象可分配。
  Future<List<String>> createAaBills({
    required String ledgerId,
    required String baseCurrency,
    String? operatorMemberId,
  }) async {
    final members = await _ensureAtLeastTwoMembers(ledgerId);
    final catIds = await _expenseCategoryIds();
    final catId = catIds[_rand.nextInt(catIds.length)];
    final base = baseCurrency.toUpperCase();
    final now = DateTime.now();
    final ids = <String>[];
    // 人均分摊：参与人运行时展开为账本全部成员，不落具体名单。
    ids.add(
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '88.00',
        categoryId: catId,
        happenedAt: now.subtract(const Duration(days: 1)),
        note: '验收-人均分摊',
        currencyCode: base,
        payerMemberId: members[0].id,
        aaMode: 0,
        operatorMemberId: operatorMemberId,
      ),
    );
    // 指定金额分摊：50 + 40 == 90，本位币口径精确合计。
    ids.add(
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '90.00',
        categoryId: catId,
        happenedAt: now.subtract(const Duration(days: 2)),
        note: '验收-指定分摊',
        currencyCode: base,
        payerMemberId: members[0].id,
        aaMode: 2,
        splits: [
          TransactionSplitInput(memberId: members[0].id, amount: '50.00'),
          TransactionSplitInput(memberId: members[1].id, amount: '40.00'),
        ],
        operatorMemberId: operatorMemberId,
      ),
    );
    // 不分摊：仅记支出人，不进入 AA 统计。
    ids.add(
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '35.50',
        categoryId: catId,
        happenedAt: now.subtract(const Duration(days: 3)),
        note: '验收-不分摊',
        currencyCode: base,
        payerMemberId: members[1].id,
        aaMode: 1,
        operatorMemberId: operatorMemberId,
      ),
    );
    return ids;
  }

  /// 新建 [count] 个虚拟用户（PLACEHOLDER 成员），返回成员 id 列表。
  Future<List<String>> createVirtualUsers({
    required String ledgerId,
    int count = 3,
  }) async {
    final ids = <String>[];
    for (var i = 0; i < count; i++) {
      ids.add(
        await repo.createPlaceholderMember(
          ledgerId: ledgerId,
          name:
              '${_virtualUserNames[i % _virtualUserNames.length]}·${suffix()}',
        ),
      );
    }
    return ids;
  }

  /// 新建本地账本：AA 开关开启 + LOCAL self 成员 + 3 个虚拟用户。
  Future<String> createLocalLedger({
    required String localSelfId,
    required String name,
    String currency = 'CNY',
  }) async {
    final id = await repo.createLedger(
      name: name,
      currency: currency,
      storageMode: 'local',
      aaEnabled: true,
      localSelfId: localSelfId,
    );
    await createVirtualUsers(ledgerId: id);
    return id;
  }

  /// 新建云端账本；[accountId] 为空（未登录）时跳过并返回 null。
  ///
  /// 账本 scopeAccountId 由仓储注入的 accountIdGetter 写入当前账号域，
  /// 创建即登记 ledger upsert 变更，由同步服务推送服务端。
  Future<String?> createCloudLedgerIfLoggedIn({
    required String? accountId,
    required String name,
  }) async {
    if (accountId == null || accountId.isEmpty) return null;
    return repo.createLedger(name: name, storageMode: 'cloud', aaEnabled: true);
  }

  /// 账本活跃成员（排除 LEFT/REMOVED 与 tombstone）。
  Future<List<LedgerMember>> _activeMembers(String ledgerId) async {
    final members = await repo.getMembersByLedger(ledgerId);
    return members.where((m) => m.status == 'ACTIVE').toList();
  }

  /// 确保账本至少两名活跃成员；不足时补建 PLACEHOLDER 虚拟用户。
  Future<List<LedgerMember>> _ensureAtLeastTwoMembers(String ledgerId) async {
    var members = await _activeMembers(ledgerId);
    while (members.length < 2) {
      await repo.createPlaceholderMember(
        ledgerId: ledgerId,
        name: '验收参与人${members.length + 1}·${suffix()}',
      );
      members = await _activeMembers(ledgerId);
    }
    return members;
  }

  /// 账本可用支出分类 id；为空时自建「验收填充」兜底分类。
  Future<List<String>> _expenseCategoryIds() async {
    final cats = await repo.getUsableCategories('expense');
    if (cats.isNotEmpty) return cats.map((c) => c.id).toList();
    final created = await repo.upsertCategory(name: '验收填充', kind: 'expense');
    return [created.id];
  }

  /// 随机金额（10.00 ~ 999.99，规范化两位小数）。
  String _randomAmount() {
    final yuan = 10 + _rand.nextInt(990);
    final cents = _rand.nextInt(100).toString().padLeft(2, '0');
    return '$yuan.$cents';
  }
}
