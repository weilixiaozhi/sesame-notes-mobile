import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late ProviderContainer container;
  var account = 'account-a';
  setUp(() {
    resetGlobalTestState();
    account = 'account-a';
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(database);
    container = ProviderContainer(
      overrides: [
        categoryDataAccessProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWith((ref) => account),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('目标选择与确认期间切号或同号重新登录均阻止旧计划', () {
    final session = captureTemplateInsertSession(container.read);
    session.assertCurrent();
    account = 'account-b';
    container.invalidate(currentAccountIdProvider);
    expect(session.assertCurrent, throwsStateError);
    final renewed = captureTemplateInsertSession(container.read);
    container.read(authSessionProvider.notifier).signOut();
    expect(renewed.assertCurrent, throwsStateError);
  });

  test('切换账本后旧模板操作不能继续提交', () {
    final session = captureTemplateInsertSession(container.read);
    container.read(currentLedgerIdProvider.notifier).set('different-ledger');
    expect(session.assertCurrent, throwsStateError);
  });
}
