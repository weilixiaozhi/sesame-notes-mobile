/// 记录详情 Bottom Sheet 展示名测试。
///
/// 锁定需求口径:
/// - 本地账本本人恒显固定本地身份「单机芝麻仔（我）」,与云昵称无关;
/// - 云/共享账本本人显当前云 Profile 昵称(我),其他成员显成员昵称;
/// - 解析不到统一「未知」,绝不裸显 member id。
/// 「我」= 当前账本 self member(ledger.selfMemberId 权威,未设置时按设备身份
/// 确定性派生),与设备 localSelfId 不是同一个值。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart' show Ledger, LedgerMember;
import 'package:sesame_notes/data/models.dart'
    show LedgerMemberDisplay, RecordEditHistoryDisplay, TransactionDisplay;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/utils/member_id.dart' show localSelfMemberId;
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart'
    show recordEditHistoryProvider;
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_detail_sheet.dart';

import '../helpers/test_isolation.dart';

/// 已登录账号状态:云昵称「云昵称」绑定 cloud-user-1。
class _CloudAccountStateNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(userId: 'cloud-user-1', displayName: '云昵称'),
  );
}

/// 渲染一个触发按钮并弹出详情 sheet。
///
/// [memberDisplayMap] 直接透传给详情 sheet;currentLedgerProvider 统一
/// override:详情 sheet 的 AA 区块与 AmountText 会 watch 它,而它内部依赖
/// repositoryProvider → databaseProvider,测试环境无平台通道,不拦掉整条链
/// pumpWidget 会因 MissingPluginException 崩溃。
/// [withCloudAccount] 为 true 时注入已登录云账号状态。
Future<void> _openSheet(
  WidgetTester tester, {
  required TransactionDisplay transaction,
  Map<String, LedgerMemberDisplay> memberDisplayMap = const {},
  String? localSelfId,
  Ledger? ledger,
  bool aaEnabled = false,
  bool withCloudAccount = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // 当前账本：详情页"我"的判定以 ledger.selfMemberId 为权威。
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(ledger),
        ),
        recordEditHistoryProvider.overrideWith(
          (ref, recordId) async => const <RecordEditHistoryDisplay>[],
        ),
        // 详情 sheet 常驻 watch 虚拟用户列表（drift 流）；测试环境无真实数据库，
        // 必须 override，否则构造真实链会在 dispose 时留下 drift 的 0ms 定时器。
        ledgerVirtualUsersProvider.overrideWith(
          (ref, ledgerId) => Stream<List<LedgerMember>>.value(const []),
        ),
        if (localSelfId != null)
          localSelfIdProvider.overrideWith((ref) async => localSelfId),
        if (withCloudAccount)
          accountStateProvider.overrideWith(_CloudAccountStateNotifier.new),
      ],
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      // 预解析身份 provider，保证 sheet 打开时 asData 已就绪。
                      ref.watch(localSelfIdProvider);
                      return const SizedBox.shrink();
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => showTransactionDetailSheet(
                      context: context,
                      transaction: transaction,
                      category: null,
                      memberDisplayMap: memberDisplayMap,
                      aaEnabled: aaEnabled,
                      onEdit: () async {},
                      onEditAa: () async {},
                      onDelete: () async {},
                    ),
                    child: const Text('打开详情'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开详情'));
  await tester.pumpAndSettle();
  // 触发日志服务的 2 秒节流保存定时器:sheet 读取 localSelfIdProvider 时
  // 首次生成会写日志并调度 Timer,测试结束前不触发会报 !timersPending。
  await tester.pump(const Duration(seconds: 3));
}

/// 构造带创建人/编辑人的交易。
TransactionDisplay _transaction({
  String? createdByMemberId = 'u_creator',
  String? lastEditedByMemberId = 'u_editor',
  int? aaMode,
  String? payerMemberId,
}) {
  return TransactionDisplay(
    id: 'tx-1',
    ledgerId: 'ledger-1',
    txType: 'expense',
    amount: '12',
    happenedAt: DateTime(2026, 1, 1, 8, 30),
    excludeFromStats: false,
    currencyCode: 'CNY',
    nativeAmount: '12',
    version: 1,
    createdByMemberId: createdByMemberId,
    lastEditedByMemberId: lastEditedByMemberId,
    aaMode: aaMode,
    payerMemberId: payerMemberId,
    createdAt: DateTime(2026, 1, 1, 8, 30),
    updatedAt: DateTime(2026, 1, 1, 8, 30),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetGlobalTestState();
  });

  testWidgets('本地账本:self member id 恒显固定本地身份「单机芝麻仔（我）」,而非裸 id', (
    tester,
  ) async {
    // 真实语义:成员 id(uuidV5 派生)与设备 localSelfId 是不同的值,
    // 「我」= ledger.selfMemberId,与设备 id 无关。
    await _openSheet(
      tester,
      transaction: _transaction(
        createdByMemberId: 'self-member-1',
        lastEditedByMemberId: 'self-member-1',
      ),
      localSelfId: 'device-1',
      ledger: Ledger(
        id: 'ledger-1',
        name: '家庭账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 1,
        monthStartDay: 1,
        storageMode: 'local',
        aaEnabled: false,
        selfMemberId: 'self-member-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    // 固定本地身份出现两次(创建人 + 编辑人),均带「(我)」后缀;成员 id 不应裸显示
    expect(
      find.textContaining('单机芝麻仔', findRichText: true),
      findsNWidgets(2),
    );
    expect(find.textContaining('(我)', findRichText: true), findsNWidgets(2));
    expect(find.text('self-member-1'), findsNothing);
    expect(find.textContaining('未设置昵称', findRichText: true), findsNothing);
  });

  testWidgets('本地账本未设置 selfMemberId:按 uuidV5(ledgerId, localSelfId) 派生判定本人', (
    tester,
  ) async {
    final derivedSelf = localSelfMemberId('ledger-1', 'device-1');
    await _openSheet(
      tester,
      transaction: _transaction(
        createdByMemberId: derivedSelf,
        lastEditedByMemberId: derivedSelf,
      ),
      localSelfId: 'device-1',
      ledger: Ledger(
        id: 'ledger-1',
        name: '家庭账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 1,
        monthStartDay: 1,
        storageMode: 'local',
        aaEnabled: false,
        selfMemberId: null,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    // 派生成员 id 被识别为本人 → 显示固定本地身份,不裸显 uuid
    expect(
      find.textContaining('单机芝麻仔', findRichText: true),
      findsNWidgets(2),
    );
    expect(find.text(derivedSelf), findsNothing);
  });

  testWidgets('云账本:本人创建人显云昵称带「(我)」,他人编辑者显成员昵称', (tester) async {
    await _openSheet(
      tester,
      transaction: _transaction(
        createdByMemberId: 'self-member-1',
        lastEditedByMemberId: 'other-member-1',
      ),
      memberDisplayMap: {
        'self-member-1': LedgerMemberDisplay(
          id: 'self-member-1',
          ledgerId: 'ledger-1',
          displayName: '旧快照昵称',
          memberType: 'REGISTERED',
          linkedAccountId: 'cloud-user-1',
          role: 'owner',
          avatarVersion: 0,
          status: 'ACTIVE',
          joinedAt: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        'other-member-1': LedgerMemberDisplay(
          id: 'other-member-1',
          ledgerId: 'ledger-1',
          displayName: '他人昵称',
          memberType: 'REGISTERED',
          linkedAccountId: 'friend-cloud-1',
          role: 'editor',
          avatarVersion: 0,
          status: 'ACTIVE',
          joinedAt: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      },
      localSelfId: 'device-1',
      withCloudAccount: true,
      ledger: Ledger(
        id: 'ledger-1',
        name: '共享账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 2,
        monthStartDay: 1,
        storageMode: 'cloud',
        aaEnabled: false,
        selfMemberId: 'self-member-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    // 本人显示当前云 Profile 昵称(而非成员行旧快照)+「(我)」;他人仅成员名
    expect(find.textContaining('云昵称', findRichText: true), findsOneWidget);
    expect(find.textContaining('他人昵称', findRichText: true), findsOneWidget);
    expect(find.textContaining('(我)', findRichText: true), findsOneWidget);
    expect(find.text('旧快照昵称'), findsNothing);
  });

  testWidgets('云账本:成员解析不到/昵称为空时统一「未知」,不裸显 id', (tester) async {
    await _openSheet(
      tester,
      transaction: _transaction(),
      memberDisplayMap: {
        'u_creator': LedgerMemberDisplay(
          id: 'u_creator',
          ledgerId: 'ledger-1',
          displayName: '',
          memberType: 'REGISTERED',
          linkedAccountId: 'u_creator',
          role: 'editor',
          avatarVersion: 0,
          status: 'ACTIVE',
          joinedAt: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      },
      withCloudAccount: true,
      ledger: Ledger(
        id: 'ledger-1',
        name: '共享账本',
        currency: 'CNY',
        role: 'owner',
        memberCount: 2,
        monthStartDay: 1,
        storageMode: 'cloud',
        aaEnabled: false,
        selfMemberId: 'self-member-1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      ),
    );

    // 昵称为空的成员与未命中成员都显示「未知」;禁止裸显 member id。
    expect(find.textContaining('未知', findRichText: true), findsNWidgets(2));
    expect(find.text('u_creator'), findsNothing);
    expect(find.text('u_editor'), findsNothing);
  });

  testWidgets('创建人/编辑人为空时不渲染协作成员区块', (tester) async {
    await _openSheet(
      tester,
      transaction: _transaction(
        createdByMemberId: null,
        lastEditedByMemberId: null,
      ),
    );

    expect(find.textContaining('单机芝麻仔', findRichText: true), findsNothing);
  });

  testWidgets('未开启分摊:底部仅常驻「编辑记账」单按钮,右上角有删除 icon', (tester) async {
    await _openSheet(tester, transaction: _transaction(), aaEnabled: false);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();

    expect(find.text('编辑记账'), findsOneWidget);
    expect(find.text('编辑分摊'), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('开启分摊:底部常驻「编辑分摊(左)+ 编辑记账(右)」双按钮', (tester) async {
    await _openSheet(tester, transaction: _transaction(), aaEnabled: true);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('编辑分摊'), findsOneWidget);
    expect(find.text('编辑记账'), findsOneWidget);
    expect(find.byType(IconButton), findsOneWidget);
  });

  testWidgets('单人参与人展示纯姓名，不再拼「（1人）」', (tester) async {
    await _openSheet(
      tester,
      transaction: _transaction(aaMode: 0, payerMemberId: 'u1'),
      aaEnabled: true,
    );

    expect(
      find.textContaining('（1人）', findRichText: true),
      findsNothing,
      reason: '单人参与人无需「（1人）」尾部',
    );
    // 未知参与人/支出人兜底渲染「未知」,不裸显 id。
    expect(
      find.textContaining('未知', findRichText: true),
      findsWidgets,
      reason: '未知参与人/支出人应兜底渲染「未知」而非原始 id',
    );
    expect(find.text('u1'), findsNothing);
  });
}
