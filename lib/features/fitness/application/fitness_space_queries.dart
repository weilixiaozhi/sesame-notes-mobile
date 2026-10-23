import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/contracts/fitness_space_repositories.dart';
import 'package:sesame_notes/shared/application/support/account_snapshot_query.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';

/// 健身空间查询保留发起时的身份，不把仓储暴露给首页和同步中心。
class FitnessSpaceQueries {
  /// 当前空间目录查询使用同一账号与会话来源。
  FitnessSpaceQueries(this._repository);
  final FitnessSpaceQueryRepository _repository;

  /// 刷新空间目录同样固定账号，结果不会被另一个会话消费。
  Future<List<FitnessSpace>> getBooks({required String? accountId}) =>
      readAccountSnapshot(
        area: 'FitnessSpaceQueries',
        accountId: accountId,
        currentAccountId: _repository.accountIdGetter,
        currentGeneration: _repository.generationGetter,
        read: () => _repository.getBooks(accountId: accountId),
      );

  /// 迟到的空间结果在账号或会话变化后失效。
  Future<FitnessSpace?> getBook(String id, {required String? accountId}) =>
      readAccountSnapshot(
        area: 'FitnessSpaceQueries',
        accountId: accountId,
        currentAccountId: _repository.accountIdGetter,
        currentGeneration: _repository.generationGetter,
        read: () => _repository.getBook(id, accountId: accountId),
      );
}

/// 空间导航与本地刷新只消费这个查询入口。
final fitnessSpaceQueriesProvider = Provider<FitnessSpaceQueries>(
  (ref) => FitnessSpaceQueries(ref.watch(fitnessSpaceQueryRepositoryProvider)),
);
