import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import '../../helpers/fitness_space_fixture.dart';

const exercise = FitnessExercise(
  id: '11111111-1111-4111-8111-111111111111',
  exerciseId: '0025',
);
final time = DateTime.utc(2026, 9, 14);

void main() {
  test('所有名称统一拒绝超长输入，嵌套名称规范化不修改原值', () {
    expect(
      () => normalizeFitnessNames({'name': '旧' * 150}),
      throwsA(isA<FitnessValidationException>()),
    );
    final input = {
      'items': [
        {'name': ' 名称 '},
      ],
    };
    final result = normalizeFitnessNames(input);
    expect((result['items'] as List).single['name'], '名称');
    expect(input['items']!.single['name'], ' 名称 ');
  });

  test('整本恢复也拒绝超长名称，不创建例外记录', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = await createFitnessTestRepository(db);
    final spaces = FitnessSpaceRepository(db);
    final source = FitnessSpace(
      id: repo.spaceId,
      name: '名称' * 75,
      createdAt: time,
      updatedAt: time,
    );
    await expectLater(
      spaces.restoreSnapshot(book: source, records: [], forceCopy: true),
      throwsFormatException,
    );
    expect(await db.select(db.fitnessSpaces).get(), hasLength(1));
  });

  test('普通导入与表单保存采用同一规范化，输入快照不被改写', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = await createFitnessTestRepository(db);
    final interactive = await repo.saveTemplate(
      const FitnessTemplate(name: '  同名  ', exercises: [exercise]),
    );
    final payload = FitnessTemplate(
      name: '  同名  ',
      exercises: const [exercise],
      createdAt: time,
      updatedAt: time,
    ).toJson();
    final before = jsonEncode(payload);
    final document = FitnessTransferDocument(
      '22222222-2222-4222-8222-222222222222',
      time,
      [
        FitnessTransferRecord(
          id: '33333333-3333-4333-8333-333333333333',
          entityType: 'fitness_template',
          fitnessSpaceId: '44444444-4444-4444-8444-444444444444',
          payload: payload,
        ),
      ],
      space: FitnessSpace(
        id: '44444444-4444-4444-8444-444444444444',
        name: '来源',
        createdAt: time,
        updatedAt: time,
      ),
    );
    await FitnessDataTransfer.importDocument(
      db: db,
      fitnessSpaceId: repo.spaceId,
      document: document,
    );
    final imported = (await repo.getTemplates()).singleWhere(
      (t) => t.id != interactive.id,
    );
    expect(interactive.name, '同名');
    expect(imported.name, interactive.name);
    expect(jsonEncode(payload), before);
    expect(
      (await FitnessDataTransfer.importDocument(
        db: db,
        fitnessSpaceId: repo.spaceId,
        document: document,
      )).skipped,
      1,
    );
  });
}
