import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_invite_sheet.dart';

import '../../helpers/test_isolation.dart';

/// 创建不访问平台和数据库的邀请结果。
LedgerInvite _invite(String code) =>
    LedgerInvite(code: code, expiresAt: DateTime.utc(2027));

/// 邀请会话覆盖网络响应与弹层生命周期的交错，不依赖真实服务端。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
  });
  tearDown(() async => logger.clear());

  test('在途重复生成只请求一次，并保持发起时的有效期', () async {
    final response = Completer<LedgerInvite>();
    final calls = <(String, int)>[];
    final controller = LedgerInviteController(
      ledgerId: 'ledger-1',
      ledgerName: '旅行',
      isReadOnly: false,
      createInvite: (id, hours) {
        calls.add((id, hours));
        return response.future;
      },
    );
    addTearDown(controller.dispose);
    controller.selectExpiry(72);
    final request = controller.generate();
    controller.selectExpiry(168);
    await controller.generate();
    expect(calls, [('ledger-1', 72)]);
    response.complete(_invite('FIRST'));
    await request;
    expect(controller.invite?.code, 'FIRST');
    expect(controller.expiresInHours, 72);
    expect(controller.isBusy, isFalse);
  });

  test('切换账本后旧请求不能覆盖新账本的邀请码或请求状态', () async {
    final oldResponse = Completer<LedgerInvite>();
    final newResponse = Completer<LedgerInvite>();
    final controller = LedgerInviteController(
      ledgerId: 'old',
      ledgerName: '旧账本',
      isReadOnly: false,
      createInvite: (id, _) =>
          id == 'old' ? oldResponse.future : newResponse.future,
    );
    addTearDown(controller.dispose);
    final oldRequest = controller.generate();
    controller.updateLedger(
      ledgerId: 'new',
      ledgerName: '新账本',
      isReadOnly: false,
    );
    final newRequest = controller.generate();
    oldResponse.complete(_invite('OLD'));
    await oldRequest;
    expect(controller.invite, isNull);
    expect(controller.isBusy, isTrue);
    newResponse.complete(_invite('NEW'));
    await newRequest;
    expect(controller.invite?.code, 'NEW');
    expect(controller.isBusy, isFalse);
  });
}
