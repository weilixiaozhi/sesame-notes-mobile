import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 记录编辑历史:某条交易的编辑历史列表,按版本号倒序。
///
/// 对应记录详情 Bottom Sheet 的"编辑记录(仅供查看)"区块。
/// 编辑历史是本地展示数据(不参与云同步),Provider 仅做读缓存;
/// 交易被编辑后由调用方主动 invalidate 此 provider 触发刷新。
final recordEditHistoryProvider = FutureProvider.family
    .autoDispose<List<RecordEditHistoryDisplay>, String>((ref, recordId) async {
      final repo = ref.watch(repositoryProvider);
      return (await repo.getEditHistories(
        recordId,
      )).map((row) => row.toDisplay()).toList(growable: false);
    });
