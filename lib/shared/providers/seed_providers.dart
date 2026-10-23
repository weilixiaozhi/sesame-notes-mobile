import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 欢迎流程的种子入口：只落默认分类模板。
///
/// 用户在业务域里新建第一条数据时按需创建默认本子，
/// 这样登录已有账号的新装应用不会凭空多出一本与云端同名的默认本子。
final ensureSeedProvider =
    Provider<Future<void> Function({AppLocalizations? l10n})>((ref) {
      return ({AppLocalizations? l10n}) async {
        try {
          final db = ref.read(databaseProvider);
          await SeedService.ensureSeed(db, l10n: l10n);
        } catch (error, stackTrace) {
          logger.error('WelcomeSeed', '默认分类初始化失败', error, stackTrace);
          rethrow;
        }
      };
    });
