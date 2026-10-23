import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_recovery_branch.dart';

String testFitnessSpaceId([String? account]) => const Uuid().v5(
  Namespace.url.value,
  'test-fitness-space:${account ?? 'local'}',
);
const testFitnessBinding = '44444444-4444-4444-8444-444444444444';
Future<String> seedFitnessTestSpace(
  SesameDatabase db, {
  String? account,
  String? id,
  bool bound = true,
}) async {
  final spaceId = id ?? testFitnessSpaceId(account);
  await db
      .into(db.fitnessSpaces)
      .insert(
        FitnessSpacesCompanion.insert(
          id: spaceId,
          name: '测试健身空间',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
          storageMode: d.Value(account == null ? 'local' : 'cloud'),
          scopeAccountId: d.Value(account),
          syncId: d.Value(account != null && bound ? testFitnessBinding : null),
          serverRevision: d.Value(
            account == null
                ? null
                : bound
                ? 1
                : 0,
          ),
          fullCursor: d.Value(account != null && bound ? '0' : null),
        ),
        mode: d.InsertMode.insertOrIgnore,
      );
  return spaceId;
}

Future<FitnessRepository> createFitnessTestRepository(
  SesameDatabase db, {
  ChangeRecorder? changeRecorder,
  String? Function()? accountIdGetter,
  int Function()? generationGetter,
  DateTime Function()? clock,
  String? spaceId,
}) async {
  final id = await seedFitnessTestSpace(
    db,
    account: accountIdGetter?.call(),
    id: spaceId,
  );
  return FitnessRepository(
    db,
    spaceId: id,
    accountIdGetter: accountIdGetter,
    generationGetter: generationGetter,
    changeRecorder: changeRecorder,
    clock: clock,
  );
}

Future<({int imported, int skipped, Map<String, String> ids})>
importFitnessFixture({
  required SesameDatabase db,
  required FitnessTransferDocument document,
  String? accountId,
  String? fitnessSpaceId,
  ChangeRecorder? changeRecorder,
  void Function()? validateContext,
  bool replaceContents = false,
  bool preservePreferenceSnapshot = false,
  List<Map<String, Object?>> receipts = const [],
  List<FitnessRecoveryBranch> branches = const [],
}) async {
  final id = await seedFitnessTestSpace(
    db,
    account: accountId,
    id: fitnessSpaceId,
  );
  return FitnessDataTransfer.importDocument(
    db: db,
    document: document,
    accountId: accountId,
    fitnessSpaceId: id,
    changeRecorder: changeRecorder,
    validateContext: validateContext,
    replaceContents: replaceContents,
    preservePreferenceSnapshot: preservePreferenceSnapshot,
    receipts: receipts,
    branches: branches,
  );
}

FitnessSpace fixtureFitnessSpace([String? id]) => FitnessSpace(
  id: id ?? testFitnessSpaceId(),
  name: '测试健身空间',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

bool fitnessTestComplete(FitnessSpaceRow row) =>
    !row.isStale &&
    (row.storageMode == 'local' ||
        row.syncId == null ||
        row.fullCursor != null);

List<Override> fitnessSpaceFixtureOverrides(FitnessRepository repository) => [
  databaseProvider.overrideWithValue(repository.db),
  fitnessSpaceRepositoryProvider.overrideWithValue(
    FitnessSpaceRepository(
      repository.db,
      accountIdGetter: repository.accountIdGetter,
      generationGetter: repository.generationGetter,
    ),
  ),
  fitnessSpacesProvider.overrideWith(
    (ref) => ref
        .read(fitnessSpaceRepositoryProvider)
        .watchBooks(accountId: repository.accountId),
  ),
  currentFitnessSpaceIdProvider.overrideWithBuild(
    (ref, notifier) async => repository.spaceId,
  ),
];
