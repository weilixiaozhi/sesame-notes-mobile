import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 首条数据创建默认本的应用能力，不暴露具体领域的仓储与状态实现。
abstract interface class DefaultBookActions {
  /// 该业务域没有可用本子时创建默认本，已有本子时返回空值。
  Future<String?> ensureDefault(AppMode mode, AppLocalizations l10n);

  /// 返回可用的账号密码本，缺失时创建并保存当前选择。
  Future<String?> ensureCredentialBook(AppLocalizations l10n);
}

/// 跨业务默认本能力由主入口注入，避免共享层装配业务实现。
final defaultBookProvisionerProvider = Provider<DefaultBookActions>(
  (ref) => throw StateError('默认本创建能力尚未装配'),
);
