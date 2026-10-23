import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/current_private_book_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import '../application/memo_providers.dart';

/// 按类型选择当前本，关闭弹窗后保留工具页和当前业务页签。
Future<void> showMemoBookPicker(
  BuildContext context,
  WidgetRef ref, {
  required String type,
}) async {
  final l = AppLocalizations.of(context);
  final account = ref.read(currentAccountIdProvider);
  final generation = ref.read(authSessionProvider.notifier).identityGeneration;
  try {
    final id = await showAppSheet<String>(
      context: context,
      child: Consumer(
        builder: (context, ref, _) {
          final books = privateBooksForDisplay(
            ref.watch(memoBooksByTypeProvider(type)),
            ref.watch(currentAccountIdProvider),
            ref.watch(memoDirectoryStatusProvider),
          );
          final selected = type == memoBookTypeCredentials
              ? ref.watch(currentCredentialBookIdProvider).value
              : ref.watch(currentMemoBookIdProvider).value;
          return AppSheet(
            title: type == memoBookTypeCredentials
                ? l.memoCredentials
                : l.memoSelectBook,
            child: books.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                logger.error('MemoBookPicker', '读取选本目录失败', error, stack);
                return AppLoadError(
                  message: l.memoLoadFailed,
                  onRetry: () async {
                    try {
                      // 本地查询和云目录状态分别刷新，网络恢复后才能退出目录失败态。
                      ref.invalidate(memoBooksProvider);
                      final result = await ref
                          .read(syncCoordinatorProvider)
                          .refreshData();
                      if (context.mounted && result.error != null) {
                        showToast(context, result.error!);
                      }
                    } catch (error, stackTrace) {
                      logger.error(
                        'MemoBookPicker',
                        '重试备忘录选本目录失败',
                        error,
                        stackTrace,
                      );
                      if (context.mounted) {
                        showToast(context, l.memoUnavailable);
                      }
                    }
                  },
                );
              },
              data: (books) => books.isEmpty
                  ? AppEmpty(text: l.memoNoBooks)
                  : ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: [
                        for (final book in books)
                          AppRadioTile(
                            title: book.name,
                            selected: book.id == selected,
                            subtitle: Text(
                              book.isCloud
                                  ? l.memoStorageCloud
                                  : l.memoStorageLocal,
                            ),
                            onTap: () => Navigator.pop(context, book.id),
                          ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
    if (id == null || !context.mounted) return;
    // 弹窗期间身份变化时丢弃选择，防止将旧账号目录写入新账号偏好。
    if (ref.read(currentAccountIdProvider) != account ||
        ref.read(authSessionProvider.notifier).identityGeneration !=
            generation) {
      showToast(context, l.memoUnavailable);
      return;
    }
    await (type == memoBookTypeCredentials
            ? ref.read(currentCredentialBookIdProvider.notifier)
            : ref.read(currentMemoBookIdProvider.notifier))
        .select(id);
  } catch (error, stack) {
    logger.error('MemoBookPicker', '选择当前本失败 type=$type', error, stack);
    if (context.mounted) showToast(context, l.memoUnavailable);
  }
}
