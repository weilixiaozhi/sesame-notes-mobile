/// ledgerIdentityProvider 统一身份上下文单测。
///
/// 锁定行为(需求锚点):
///   1. 本地账本 self 恒显固定本地身份「单机芝麻仔」,且注入云昵称无效(I-04);
///   2. 云账本 self 优先当前云 Profile 昵称(本地缓存,离线可用);
///   3. 共享账本即使 storageMode 未回填 'cloud',也必须按云账本口径解析
///      (统一谓词 storageMode=='cloud' || memberCount>1);
///   4. self_member_id 缺失时按「绑定当前账号的 REGISTERED 成员」解析本人,
///      不再裸回退设备 id 导致「未知」;
///   5. 未知参与人统一「未知」,绝不裸显 member id;
///   6. 虚拟用户名解析与「(我)」判定(本人 = self id / LOCAL / 绑定账号)。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'dart:ui' show Locale;

/// 固定中文语言环境。
class _ZhLanguageNotifier extends LanguageNotifier {
  @override
  Locale? build() => const Locale('zh');
}

/// 已登录云账号状态:昵称「云昵称」。
class _CloudAccountNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(userId: 'cloud-user-1', displayName: '云昵称'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  ProviderContainer buildContainer({bool cloudAccount = false}) {
    final c = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
        languageProvider.overrideWith(_ZhLanguageNotifier.new),
        if (cloudAccount)
          accountStateProvider.overrideWith(_CloudAccountNotifier.new),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 插入一个共享账本行(memberCount>1,storageMode 可自定义)。
  Future<String> seedLedger({required String storageMode}) async {
    const ledgerId = 'led-shared-1';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '共享账本',
            memberCount: d.Value(2),
            role: d.Value('owner'),
            aaEnabled: d.Value(true),
            storageMode: d.Value(storageMode),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    return ledgerId;
  }

  /// 插入绑定当前云账号的 REGISTERED 本人成员行(displayName 可空)。
  Future<void> seedBoundSelf(
    String ledgerId, {
    String displayName = 'Owner',
  }) async {
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'u-owner',
            ledgerId: ledgerId,
            displayName: displayName,
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value('cloud-user-1'),
            role: const d.Value('editor'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
  }

  test('本地账本：self 恒显固定本地身份，云昵称不注入（I-04）', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
      aaEnabled: true,
    );
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    final selfMemberId = localSelfMemberId(ledgerId, 'local-self');
    expect(
      identity.selfMemberId,
      selfMemberId,
      reason: '本地账本 self = 确定性派生的 LOCAL 成员',
    );
    expect(
      identity.displayNameOf(selfMemberId),
      '单机芝麻仔',
      reason: '本地身份与云身份独立,已登录也不得显示云昵称',
    );
    expect(identity.isSelfOf(selfMemberId), isTrue);
  });

  test('云账本无成员行：self 回退设备身份并显云昵称', () async {
    final ledgerId = await repo.createLedger(
      name: '云账本',
      storageMode: 'cloud',
      aaEnabled: true,
    );
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.selfMemberId, 'local-self', reason: '云账本无绑定信息时回退设备身份兜底');
    expect(identity.displayNameOf('local-self'), '云昵称');
    expect(identity.isSelfOf('local-self'), isTrue);
  });

  test('共享账本 storageMode 未回填 cloud：本人仍显云昵称并标记「我」', () async {
    final ledgerId = await seedLedger(storageMode: 'local');
    await seedBoundSelf(ledgerId);
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(
      identity.displayNameOf('u-owner'),
      '云昵称',
      reason: '共享账本(memberCount>1)必须按云账本口径解析,不得退回本地身份口径',
    );
    expect(identity.isSelfOf('u-owner'), isTrue);
  });

  test('self_member_id 缺失：按绑定当前账号的 REGISTERED 成员解析本人', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    await seedBoundSelf(ledgerId);
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(
      identity.selfMemberId,
      'u-owner',
      reason: '绑定成员存在时 self 必须是该成员,不能裸回退设备 id',
    );
  });

  test('资料缓存未就绪：本人回退成员行昵称,再回退「未知」', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    // 不登录:云昵称不可用,回退成员行昵称。
    await seedBoundSelf(ledgerId, displayName: 'Owner');
    final c = buildContainer();

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.displayNameOf('u-owner'), 'Owner');

    // 成员行昵称为空:防御性兜底「未知」,绝不裸显 id。
    await (db.update(db.ledgerMembers)..where((m) => m.id.equals('u-owner')))
        .write(const LedgerMembersCompanion(displayName: d.Value('')));
    c.invalidate(ledgerIdentityProvider(ledgerId));
    final refreshed = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(refreshed.displayNameOf('u-owner'), '未知');
  });

  test('未知参与人统一「未知」,虚拟用户解析自身名称', () async {
    final ledgerId = await seedLedger(storageMode: 'cloud');
    await seedBoundSelf(ledgerId);
    await repo.createPlaceholderMember(
      ledgerId: ledgerId,
      name: '室友A',
      id: 'vu-1',
    );
    final c = buildContainer(cloudAccount: true);

    final identity = await readProviderFutureFromContainer(
      c,
      ledgerIdentityProvider(ledgerId).future,
    );
    expect(identity.displayNameOf('vu-1'), '室友A');
    expect(identity.isSelfOf('vu-1'), isFalse);
    expect(identity.displayNameOf('foreign-id'), '未知');
    expect(identity.displayNameOf(null), '未知');
  });
}
