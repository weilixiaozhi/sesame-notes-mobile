/// 保证下拉刷新至少展示 [minimum] 时长。
///
/// 内置 RefreshIndicator 的 onRefresh 若由本地查询瞬时完成，转圈指示器
/// 会一闪而过。把实际刷新任务包进本函数：
/// - 任务更快时凑满最小展示时长后再收尾；
/// - 任务更慢时按任务自身耗时收尾，不额外追加；
/// - 任务失败（含同步抛出）时错误延迟到最小展示时长后才抛出，
///   指示器不因报错提前收起。
Future<T> ensureMinimumRefreshDuration<T>(
  Future<T> Function() task, {
  Duration minimum = const Duration(seconds: 1),
}) async {
  // Future.sync 把任务同步抛出的异常也收编为失败 Future，走统一等待链。
  final future = Future.sync(task);
  // eagerError: false：等待链必须等最小展示时长走完才结束。
  // 任务结果先转成 void 并吞掉错误，失败由下方 return future 重新抛出，
  // 保证错误传播时机同样不早于最小展示时长。
  await Future.wait<void>([
    Future<void>.delayed(minimum),
    future.then<void>((_) {}, onError: (_) {}),
  ], eagerError: false);
  // future 此刻必然已完成：成功则透传结果，失败则在此抛出原始错误。
  return future;
}
