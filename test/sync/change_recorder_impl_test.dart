import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';

void main() {
  test('每条本地变更持久化独立的 UUIDv4 mutation_id', () async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final recorder = ChangeRecorderImpl(db);

    for (var index = 0; index < 2; index++) {
      await recorder.recordUserGlobalChange(
        entityType: 'category',
        entityId: 'category-$index',
        action: 'upsert',
        payload: '{}',
        updatedAt: DateTime.utc(2026, 8, 20),
      );
    }

    final changes = await db.select(db.syncChanges).get();
    expect(changes.map((change) => change.mutationId).toSet(), hasLength(2));
    for (final change in changes) {
      expect(Uuid.isValidUUID(fromString: change.mutationId), isTrue);
      expect(change.mutationId[14], '4');
    }
  });
}
