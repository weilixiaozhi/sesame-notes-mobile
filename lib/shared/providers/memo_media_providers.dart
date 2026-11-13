import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/repositories/local/memo_media_repository.dart';
import 'package:sesame_notes/data/services/memo_media_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/media/memo_media_api.dart';

import 'account_state_provider.dart';
import 'database_providers.dart';

/// 图片本地存储随数据库实例装配。
final memoMediaRepositoryProvider = Provider<MemoMediaRepository>(
  (ref) => MemoMediaRepository(ref.watch(databaseProvider)),
);

/// 图片编排随当前 API 客户端与账号域重建，未登录时只处理本机图片。
final memoMediaServiceProvider = Provider<MemoMediaService>((ref) {
  return MemoMediaService(
    repository: ref.watch(memoMediaRepositoryProvider),
    api: MemoMediaApi(ref.watch(apiClientProvider).dio),
    accountId: () => ref.read(currentAccountIdProvider),
  );
});

/// 编辑器按图片标识读取字节；同一标识在监听期间复用同一结果。
final memoMediaBytesProvider = FutureProvider.family<Uint8List?, String>(
  (ref, id) => ref.watch(memoMediaServiceProvider).bytesOf(id),
);
