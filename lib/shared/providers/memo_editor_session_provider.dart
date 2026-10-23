import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主动切换账号前请求打开的编辑页保存或确认放弃；被动失效只隔离草稿。
final memoEditorLeaveGuardsProvider = Provider(
  (ref) => <Future<bool> Function()>{},
);
