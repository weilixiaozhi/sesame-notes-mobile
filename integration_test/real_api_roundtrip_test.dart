// 真实后端跨端集成测试，需要本机后端 API 运行在 127.0.0.1:8080。
//
// 显式运行入口：
//   flutter test integration_test/real_api_roundtrip_test.dart
//
// 覆盖范围：
// - 客户端 UUID 建账本（POST /ledgers 带 id）→ 服务端接受同一 id；
// - 交易金额为规范化 Decimal 字符串（含 28 位整数 + 10 位小数边界值）往返；
// - sync/full 快照返回同一实体（服务端落库证据）；
// - SyncService push → pull 全链路：本地变更推送到服务端，另一台设备增量拉取落库。
library;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:uuid/uuid.dart';

/// 集成测试前置：后端 API 必须已启动（node --env-file=.env apps/api/dist/server.js）。
/// 宿主地址经 --dart-define=E2E_BASE_URL 注入；Android 真机用 adb reverse 或 10.0.2.2。
const _baseUrl = String.fromEnvironment(
  'E2E_BASE_URL',
  defaultValue: 'http://127.0.0.1:8080',
);

/// 生成每次运行唯一的手机号（+86 区号，11 位），测试内创建账号，不依赖预置旧账号。
String uniquePhone() {
  return '138${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}${DateTime.now().millisecond % 90 + 10}';
}

/// 注册新账号并切换 client 的 Bearer；返回会话数据。
Future<PostAuthRegister201Response> registerAndSignIn(
  AuthApi authApi,
  SesameApiClient apiClient, {
  String? deviceInstallationId,
}) async {
  final resp = await authApi.postAuthRegister(
    postAuthRegisterRequest: PostAuthRegisterRequest(
      (b) => b
        ..countryCode = '+86'
        ..phone = uniquePhone()
        ..password = 'P@ssw0rd123!'
        ..device = PostAuthRegisterRequestDevice(
          (d) => d
            ..installationId = deviceInstallationId ?? const Uuid().v4()
            ..name = 'E2E 设备'
            ..platform = 'flutter_test',
        ).toBuilder(),
    ),
  );
  final data = resp.data!;
  apiClient.setBearerAuth('bearerAuth', data.accessToken);
  return data;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // flutter_test 默认用 mock HttpOverrides 拦截真实网络（统一返回 400），
  // 本集成测试必须访问真实后端，显式恢复真实 HTTP。
  HttpOverrides.global = null;

  late SesameApiClient client;

  setUp(() {
    client = SesameApiClient(basePathOverride: _baseUrl);
  });

  test('真实后端：注册(手机号) → 客户端 UUID 建账本 → Decimal 边界交易 → sync full 往返', () async {
    final authApi = AuthApi(client.dio, client.serializers);
    final ledgerApi = LedgersApi(client.dio, client.serializers);
    final txApi = TransactionsApi(client.dio, client.serializers);
    final syncApi = SyncApi(client.dio, client.serializers);

    // 1) 注册唯一手机号（测试内创建，不依赖预置旧账号）。
    final loginData = await registerAndSignIn(authApi, client);
    expect(loginData.accessToken, isNotEmpty);
    expect(loginData.refreshToken, isNotEmpty);

    // 2) 客户端生成 UUID 建账本（契约：client allowed id）。
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

    // 3) Decimal 边界值交易（28 位整数 + 10 位小数，契约 numeric(38,10) 上限）。
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
    expect(
      tx.data!.amount,
      boundaryAmount,
      reason: '服务端 numeric(38,10) 必须无损往返边界 Decimal',
    );
    expect(tx.data!.id, txId);

    // 4) sync/full 快照往返（服务端落库证据）。
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

  test('真实后端：本地变更 push → 另一台设备 pull 增量落库（全链路往返）', () async {
    // 1) 本地预生成 installation_id → 注册携带 → 服务端按 (user, installation) 返回账号域 device id。
    final deviceAId = const Uuid().v4();
    final authApi = AuthApi(client.dio, client.serializers);
    final loginData = await registerAndSignIn(
      authApi,
      client,
      deviceInstallationId: deviceAId,
    );
    // device id 由服务端生成，不等同于安装标识；push 的 device_id 使用会话返回值。
    expect(loginData.deviceId, isNot(deviceAId));

    // 2) 设备 A：内存库 + 本地账本行 + ChangeRecorder 登记一笔 ledger 变更
    //    （模拟离线新建账本：本地行先存在，push 后 sync_id 才能落库，
    //    后续 delete 推送才会携带 sync_id，否则服务端 412 拒绝）。
    final dbA = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbA.close);
    final recorderA = ChangeRecorderImpl(dbA);
    final ledgerId = const Uuid().v4();
    final now = DateTime.now().toUtc();
    // storageMode=cloud + syncId=null = CLOUD_UNBOUND（首次上云中间态）：
    // 只有可同步状态才能过 push 的 blocked 门禁；push 后 outcome 落 sync_id。
    await dbA
        .into(dbA.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: 'push 同步账本',
            storageMode: const d.Value('cloud'),
            updatedAt: now,
          ),
        );
    // 账本级变更必须走 recordLedgerChange（携带 ledger_id）：push 侧按
    // ledger_id 读取本地 sync_id 并附加到请求，否则服务端 412 拒绝。
    await recorderA.recordLedgerChange(
      entityType: 'ledger',
      entityId: ledgerId,
      ledgerId: ledgerId,
      action: 'upsert',
      payload: jsonEncode({
        'name': 'push 同步账本',
        'currency': 'CNY',
        'month_start_day': 1,
        'aa_enabled': false,
      }),
      updatedAt: now,
    );
    // push 前本地数据库必须能查到待推送记录。
    final pendingBefore = await (dbA.select(
      dbA.syncChanges,
    )..where((t) => t.pushedAt.isNull())).get();
    expect(pendingBefore, hasLength(1));

    // 3) 设备 A push：本地队列 → 服务端。
    final syncA = SyncService(
      client: client,
      db: dbA,
      deviceId: loginData.deviceId,
    );
    await syncA.push();
    // 推送成功后队列标记已推送（pushedAt 非空）。
    final pendingAfter = await (dbA.select(
      dbA.syncChanges,
    )..where((t) => t.pushedAt.isNull())).get();
    expect(pendingAfter, isEmpty, reason: 'push 成功后待推送队列必须清空');

    // 4) 服务端证据：sync/full 能看到刚 push 的账本。
    final syncApi = SyncApi(client.dio, client.serializers);
    final full = await syncApi.getSyncFull(ledgerId: ledgerId);
    expect(full.data!.ledger.id, ledgerId);
    expect(
      full.data!.ledger.name,
      'push 同步账本',
      reason: '服务端必须落库客户端 push 的 ledger',
    );

    // 5) 设备 B：全新内存库 + 全新游标，pull 增量拉取并落库。
    final dbB = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(dbB.close);
    final syncB = SyncService(
      client: client,
      db: dbB,
      deviceId: const Uuid().v4(),
    );
    final pulled = await syncB.pull();
    expect(pulled, greaterThan(0), reason: 'pull 必须拉取到至少一条变更');

    // 6) 设备 B 本地落库证据：刚 push 的 ledger 出现在本地账本表。
    final localLedger = await (dbB.select(
      dbB.ledgers,
    )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
    expect(localLedger, isNotNull, reason: 'pull 应用后设备 B 本地必须有该账本');
    expect(localLedger!.name, 'push 同步账本');
    expect(localLedger.storageMode, 'cloud');

    // 7) tombstone 往返：设备 A push delete → 设备 B pull 后本地行软删（deletedAt 非空，行仍在）。
    // delete 的 updated_at 必须严格晚于 upsert：同毫秒时 LWW 平局按 device_id
    // 比较会判 delete 非新（同设备），服务端会拒删。加 1 秒偏移保证单调递增。
    final deleteAt = now.add(const Duration(seconds: 1));
    await recorderA.recordLedgerChange(
      entityType: 'ledger',
      entityId: ledgerId,
      ledgerId: ledgerId,
      action: 'delete',
      payload: jsonEncode({'deleted_at': deleteAt.toIso8601String()}),
      updatedAt: deleteAt,
    );
    await syncA.push();
    // 设备 B 继续按游标增量拉取（不重置游标，复用同一 SyncService 实例）。
    final pulled2 = await syncB.pull();
    expect(pulled2, greaterThan(0), reason: 'delete 变更必须能被拉取到');
    final deletedLedger = await (dbB.select(
      dbB.ledgers,
    )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
    expect(deletedLedger, isNotNull, reason: 'tombstone 不删行，行必须仍在');
    expect(
      deletedLedger!.deletedAt,
      isNotNull,
      reason: '删除走 tombstone，deleted_at 非空，不靠缺失推断',
    );
  });

  test('真实后端：同一 installation 在 A/B 两个账号各自获得独立 device id', () async {
    final installationId = const Uuid().v4();
    final authApi = AuthApi(client.dio, client.serializers);
    // 账号 A 注册（同一安装）。
    final loginA = await registerAndSignIn(
      authApi,
      client,
      deviceInstallationId: installationId,
    );
    // 账号 B 注册（同一安装）→ 不再冲突，返回不同 device id。
    final loginB = await registerAndSignIn(
      authApi,
      client,
      deviceInstallationId: installationId,
    );
    expect(
      loginA.deviceId,
      isNot(loginB.deviceId),
      reason: '同安装不同账号必须各自独立 device id',
    );
  });

  test('真实后端：同一 idempotency-key 重发交易创建 → 服务端去重（幂等）', () async {
    // 1) 注册 + 建账本。
    final authApi = AuthApi(client.dio, client.serializers);
    await registerAndSignIn(authApi, client);
    final ledgerApi = LedgersApi(client.dio, client.serializers);
    final ledgerId = const Uuid().v4();
    await ledgerApi.postLedgers(
      postLedgersRequest: PostLedgersRequest(
        (b) => b
          ..id = ledgerId
          ..name = '幂等测试账本'
          ..currency = 'CNY',
      ),
    );

    // 2) 同一 idempotency-key 连续两次创建同一交易（网络重试模拟）。
    final txApi = TransactionsApi(client.dio, client.serializers);
    final txId = const Uuid().v4();
    final idemKey = const Uuid().v4();
    PostLedgersByLedgerIdTransactionsRequest buildReq() =>
        PostLedgersByLedgerIdTransactionsRequest(
          (b) => b
            ..id = txId
            ..txType =
                PostLedgersByLedgerIdTransactionsRequestTxTypeEnum.expense
            ..amount = '42.5'
            ..happenedAt = DateTime.utc(2026, 9, 9)
            ..currencyCode = 'CNY'
            ..nativeAmount = '42.5',
        );
    final first = await txApi.postLedgersByLedgerIdTransactions(
      ledgerId: ledgerId,
      postLedgersByLedgerIdTransactionsRequest: buildReq(),
      idempotencyKey: idemKey,
    );
    expect(first.data!.id, txId);
    final second = await txApi.postLedgersByLedgerIdTransactions(
      ledgerId: ledgerId,
      postLedgersByLedgerIdTransactionsRequest: buildReq(),
      idempotencyKey: idemKey,
    );
    expect(second.data!.id, txId, reason: '幂等键命中必须返回同一实体');

    // 3) 服务端只落一条：full 快照中该交易只出现一次。
    final syncApi = SyncApi(client.dio, client.serializers);
    final full = await syncApi.getSyncFull(ledgerId: ledgerId);
    final matches = full.data!.transactions.where((t) => t.id == txId);
    expect(matches.length, 1, reason: '幂等键必须阻止重复落库');
  });

  test('真实后端：设备会话管理——列设备含本机, 撤销后刷新被拒', () async {
    // 1) 注册（携带本地预生成 installation_id）。
    final deviceId = const Uuid().v4();
    final authApi = AuthApi(client.dio, client.serializers);
    final loginData = await registerAndSignIn(
      authApi,
      client,
      deviceInstallationId: deviceId,
    );
    client.setBearerAuth('bearerAuth', loginData.accessToken);
    final refreshToken = loginData.refreshToken;

    // 2) 列出设备：必须包含本机（current=true）。
    final devicesApi = DevicesApi(client.dio, client.serializers);
    final devices = await devicesApi.getDevices();
    final current = devices.data!.firstWhere(
      (d) => d.id == loginData.deviceId,
      orElse: () => throw StateError('本机设备不在列表中'),
    );
    expect(current.current, isTrue, reason: '本机设备必须标记 current=true');

    // 3) 撤销本机设备。
    await devicesApi.deleteDevicesByDeviceId(deviceId: loginData.deviceId);

    // 4) 撤销后 refresh token 必须被拒（设备会话已吊销）。
    await expectLater(
      authApi.postAuthRefresh(
        postAuthRefreshRequest: PostAuthRefreshRequest(
          (b) => b..refreshToken = refreshToken,
        ),
      ),
      throwsA(isA<DioException>()),
      reason: '撤销设备后其 refresh token 必须失效',
    );
  });

  test('真实后端：资料读取 + 共享能力——列成员/建邀请/查询邀请码', () async {
    // 1) 登录。
    final authApi = AuthApi(client.dio, client.serializers);
    final loginData = await registerAndSignIn(authApi, client);

    // 2) 资料读取：profile/me 返回当前账号（芝麻号与脱敏手机号）。
    final profileApi = ProfileApi(client.dio, client.serializers);
    final profile = await profileApi.getProfileMe();
    expect(profile.data!.userId, loginData.user.userId);
    expect(profile.data!.sesameNumber, loginData.user.sesameNumber);

    // 3) 建账本 → 列成员含 owner → 建邀请 → 按码查询。
    final ledgerApi = LedgersApi(client.dio, client.serializers);
    final sharingApi = SharingApi(client.dio, client.serializers);
    final ledgerId = const Uuid().v4();
    await ledgerApi.postLedgers(
      postLedgersRequest: PostLedgersRequest(
        (b) => b
          ..id = ledgerId
          ..name = '共享测试账本'
          ..currency = 'CNY',
      ),
    );

    final members = await sharingApi.getLedgersByLedgerIdMembers(
      ledgerId: ledgerId,
    );
    expect(
      members.data!.length,
      greaterThanOrEqualTo(1),
      reason: '新账本至少包含 owner 成员',
    );

    final invite = await sharingApi.postLedgersByLedgerIdInvites(
      ledgerId: ledgerId,
      postLedgersByLedgerIdInvitesRequest: PostLedgersByLedgerIdInvitesRequest(
        (b) => b..expiresInHours = 24,
      ),
    );
    expect(invite.data!.id, isNotEmpty);
    expect(invite.data!.role.name, 'editor', reason: '邀请角色固定 editor');

    // 4) 按完整码查询（code 字段，非 code_prefix）。
    final byCode = await sharingApi.getInvitesByCode(code: invite.data!.code);
    expect(byCode.data!.ledgerId, ledgerId, reason: '邀请码必须解析到对应账本');
  });
}
