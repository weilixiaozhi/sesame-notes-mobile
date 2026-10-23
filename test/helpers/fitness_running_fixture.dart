import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';

Future<FitnessWorkout> runningWorkoutFixture(
  FitnessRepository repo, {
  String name = '训练',
  String? id,
}) async {
  final draft = await repo.createBlankWorkout(name: name, id: id);
  return repo.startWorkout(draft.id);
}
