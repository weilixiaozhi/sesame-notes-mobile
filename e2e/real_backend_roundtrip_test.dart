// 真实后端 headless 跨端往返测试。
//
// 显式运行入口：
//   flutter test e2e/real_backend_roundtrip_test.dart
//
// 覆盖:登录 → 客户端 UUID 建账本 → Decimal 边界交易 → sync/full 快照 →
// SyncService push → 另一台设备 pull 增量落库(含 mutation_id 幂等与 410 处理路径)。
//
// 本机后端启动（详见主仓库 sesame-notes）：
//   1. docker compose -f deploy/docker-compose.dev.yml up -d postgres
//   2. docker compose -f deploy/docker-compose.dev.yml run --rm api node apps/api/node_modules/prisma/build/index.js migrate deploy --schema apps/api/prisma/schema.prisma
//   3. docker compose -f deploy/docker-compose.dev.yml up -d api
//   4. 自检: curl http://127.0.0.1:8080/api/v1/health
// 默认连接 127.0.0.1:8080;其他地址用 --dart-define=E2E_BASE_URL=... 覆盖。
// 后端不可达时测试直接失败；每次运行注册唯一手机号，不依赖预置账号。
// push 的 device_id 必须用服务端返回的 deviceId(非 installation_id)。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:uuid/uuid.dart';

const _baseUrl = String.fromEnvironment(
  'E2E_BASE_URL',
  defaultValue: 'http://127.0.0.1:8080',
);

/// 生成每次运行唯一的手机号（+86 区号，11 位），避免依赖预置旧账号。
String uniquePhone() {
  return '138${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}${DateTime.now().millisecond % 90 + 10}';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test 的 binding 默认注入 mock HttpClient,这里显式恢复真实网络。
  HttpOverrides.global = null;

  setUpAll(() async {
    final dio = Dio(BaseOptions(baseUrl: _baseUrl));
    try {
      final resp = await dio
          .get('/api/v1/health')
          .timeout(const Duration(seconds: 2));
      if (resp.statusCode != 200) {
        fail('后端健康检查返回 ${resp.statusCode}，真实后端测试禁止跳过');
      }
    } catch (error, stackTrace) {
      printOnFailure('真实后端健康检查失败: $error\n$stackTrace');
      fail('后端不可达，真实后端测试禁止跳过。请先在 sesame-notes 主仓库按文件头命令启动 PostgreSQL 和 API。');
    }
  });

  late SesameApiClient client;

  setUp(() {
    client = SesameApiClient(basePathOverride: _baseUrl);
  });

  test('真实后端:登录 → 客户端 UUID 建账本 → Decimal 边界交易 → sync full 往返', () async {
    final authApi = AuthApi(client.dio, client.serializers);
    final ledgerApi = LedgersApi(client.dio, client.serializers);
    final txApi = TransactionsApi(client.dio, client.serializers);
    final syncApi = SyncApi(client.dio, client.serializers);

    final phone = uniquePhone();
    final login = await authApi.postAuthRegister(
      postAuthRegisterRequest: PostAuthRegisterRequest(
        (b) => b
          ..countryCode = '+86'
          ..phone = phone
          ..password = 'P@ssw0rd123!'
          ..device = PostAuthRegisterRequestDevice(
            (d) => d
              ..installationId = const Uuid().v4()
              ..name = 'E2E 设备'
              ..platform = 'flutter_test',
          ).toBuilder(),
      ),
    );
    final loginData = login.data!;
    expect(loginData.accessToken, isNotEmpty);
    client.setBearerAuth('bearerAuth', loginData.accessToken);

    final ledgerId = const Uuid().v4();
    final ledger = await ledgerApi.postLedgers(
      postLedgersRequest: PostLedgersRequest(
        (b) => b
          ..id = ledgerId
          ..name = 'E2E 往返账本'
          ..currency = 'CNY',
      ),
    );
    expect(ledger.data!.id, ledgerId, reason: '服务端必须接受并原样保存客户端 UUID');

    // Decimal 边界值(28 位整数 + 10 位小数,numeric(38,10) 上限)无损往返。
    const boundaryAmount = '99999999999999999999.9999999999';
    final txId = const Uuid().v4();
    final tx = await txApi.postLedgersByLedgerIdTransactions(
      ledgerId: ledgerId,
      postLedgersByLedgerIdTransactionsRequest:
          PostLedgersByLedgerIdTransactionsRequest(
            (b) => b
              ..id = txId
              ..txType =
                  PostLedgersByLedgerIdTransactionsRequestTxTypeEnum.expense
              ..amount = boundaryAmount
              ..happenedAt = DateTime.utc(2026, 8, 8)
              ..currencyCode = 'CNY'
              ..nativeAmount = boundaryAmount,
          ),
    );
    expect(tx.data!.amount, boundaryAmount);
    expect(tx.data!.id, txId);

    final full = await syncApi.getSyncFull(ledgerId: ledgerId);
    expect(full.data!.ledger.id, ledgerId);
    expect(
      full.data!.transactions.any(
        (t) => t.id == txId && t.amount == boundaryAmount,
      ),
      isTrue,
      reason: 'full 快照必须包含刚创建的边界金额交易',
    );
  });

  test('真实后端:本地变更 push(mutation_id) → 另一台设备 pull 增量落库', () async {
    final deviceAId = const Uuid().v4();
    final authApi = AuthApi(client.dio, client.serializers);
    final login = await authApi.postAuthRegister(
      postAuthRegisterRequest: PostAuthRegisterRequest(
        (b) => b
          ..countryCode = '+86'
          ..phone = uniquePhone()
          ..password = 'P@ssw0rd123!'
          ..device = PostAuthRegisterRequestDevice(
            (b) => b
              ..installationId = deviceAId
              ..name = 'E2E 设备 A'
              ..platform = 'flutter_test',
          ).toBuilder(),
      ),
    );
    final loginData = login.data!;
    client.setBearerAuth('bearerAuth', loginData.accessToken);

    final dbA = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbA.close);
    final recorderA = ChangeRecorderImpl(dbA);
    final ledgerId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    await recorderA.recordUserGlobalChange(
      entityType: 'ledger',
      entityId: ledgerId,
      action: 'upsert',
      payload: jsonEncode({
        'name': 'push 同步账本',
        'currency': 'CNY',
        'month_start_day': 1,
        'aa_enabled': false,
      }),
      updatedAt: now,
    );

    // push 的 device_id 必须是服务端返回的设备标识（session deviceId），
    // 注册请求里的 installation_id 只是安装级标识，两者不可混用（服务端 DEVICE_MISMATCH 403）。
    final syncA = SyncService(
      client: client,
      db: dbA,
      deviceId: loginData.deviceId,
    );
    await syncA.push();
    final pendingAfter = await (dbA.select(
      dbA.syncChanges,
    )..where((t) => t.pushedAt.isNull())).get();
    expect(pendingAfter, isEmpty, reason: 'push 成功后待推送队列必须清空');

    // 服务端证据:full 能看到 push 的账本(服务端已落库)。
    final syncApi = SyncApi(client.dio, client.serializers);
    final full = await syncApi.getSyncFull(ledgerId: ledgerId);
    expect(full.data!.ledger.name, 'push 同步账本');

    // 设备 B:全新内存库 + 游标 0,pull 增量拉取。
    final dbB = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbB.close);
    final syncB = SyncService(
      client: client,
      db: dbB,
      deviceId: const Uuid().v4(),
    );
    await syncB.pull();
    final pulled = await (dbB.select(dbB.ledgers)).get();
    expect(
      pulled.any((l) => l.id == ledgerId && l.name == 'push 同步账本'),
      isTrue,
      reason: '设备 B pull 必须落库设备 A push 的账本',
    );
  });
  test(
    '真实后端：成员镜像联调——owner member/member_id/status 解析、canonical PATCH/DELETE、member_count、member-stats',
    () async {
      final authApi = AuthApi(client.dio, client.serializers);
      final ledgerApi = LedgersApi(client.dio, client.serializers);
      final sharingApi = SharingApi(client.dio, client.serializers);

      // 注册唯一手机号（测试内创建，不依赖预置旧账号）
      final login = await authApi.postAuthRegister(
        postAuthRegisterRequest: PostAuthRegisterRequest(
          (b) => b
            ..countryCode = '+86'
            ..phone = uniquePhone()
            ..password = 'P@ssw0rd123!'
            ..device = PostAuthRegisterRequestDevice(
              (d) => d
                ..installationId = const Uuid().v4()
                ..name = 'E2E 设备'
                ..platform = 'flutter_test',
            ).toBuilder(),
        ),
      );
      final owner = login.data!.user;
      client.setBearerAuth('bearerAuth', login.data!.accessToken);

      // member_count 语义 = ACTIVE 成员数（含 Owner）= 1
      final ledgerId = const Uuid().v4();
      final ledger = await ledgerApi.postLedgers(
        postLedgersRequest: PostLedgersRequest(
          (b) => b
            ..id = ledgerId
            ..name = '成员镜像联调'
            ..currency = 'CNY',
        ),
      );
      expect(ledger.data!.memberCount, 1, reason: 'member_count 必须含 Owner');

      // GET /members：Owner 是一等成员——member_id 按 golden 派生、status=ACTIVE、linked_account_id=账号 id
      final members = await sharingApi.getLedgersByLedgerIdMembers(
        ledgerId: ledgerId,
      );
      expect(members.data!.length, 1);
      final ownerItem = members.data!.first;
      expect(
        ownerItem.memberId,
        registeredMemberId(ledgerId, owner.userId),
        reason: '客户端派生 member_id 必须与服务端 golden 一致',
      );
      expect(ownerItem.status.name, 'ACTIVE');
      expect(ownerItem.linkedAccountId, owner.userId);
      expect(ownerItem.role.name, 'owner');

      // 注册第二账号 → 邀请 → 接受 → 成员列表出现 editor（member_id 按新账号派生）
      final reg = await authApi.postAuthRegister(
        postAuthRegisterRequest: PostAuthRegisterRequest(
          (b) => b
            ..countryCode = '+86'
            ..phone = uniquePhone()
            ..password = 'password-123456'
            ..device = (PostAuthRegisterRequestDevice(
              (b) => b
                ..installationId = const Uuid().v4()
                ..name = 'E2E 设备 B'
                ..platform = 'flutter_test',
            ).toBuilder()),
        ),
      );
      final member = reg.data!.user;
      final invite = await sharingApi.postLedgersByLedgerIdInvites(
        ledgerId: ledgerId,
        postLedgersByLedgerIdInvitesRequest:
            PostLedgersByLedgerIdInvitesRequest((b) => b),
      );
      final inviteCode = invite.data!.code;
      client.setBearerAuth('bearerAuth', reg.data!.accessToken);
      await sharingApi.postInvitesByCodeAccept(code: inviteCode);
      client.setBearerAuth('bearerAuth', login.data!.accessToken);

      final members2 = await sharingApi.getLedgersByLedgerIdMembers(
        ledgerId: ledgerId,
      );
      expect(members2.data!.length, 2);
      final editorItem = members2.data!.firstWhere(
        (m) => m.userId == member.userId,
      );
      expect(editorItem.memberId, registeredMemberId(ledgerId, member.userId));
      expect(editorItem.status.name, 'ACTIVE');
      expect(editorItem.role.name, 'editor');

      // 成员角色固定 owner/editor（无只读档）：角色变更接口已移除

      // canonical DELETE by member_id：成员列表只剩 owner
      await sharingApi.deleteLedgersByLedgerIdMembersByMemberId(
        ledgerId: ledgerId,
        memberId: editorItem.memberId,
      );
      final members3 = await sharingApi.getLedgersByLedgerIdMembers(
        ledgerId: ledgerId,
      );
      expect(members3.data!.length, 1);

      // member-stats：items 含 member_id 维度（owner）
      final stats = await sharingApi.getLedgersByLedgerIdMemberStats(
        ledgerId: ledgerId,
      );
      expect(
        stats.data!.items.any((i) => i.memberId == ownerItem.memberId),
        isTrue,
        reason: 'member-stats 必须返回 canonical member_id 维度',
      );
    },
  );
}
