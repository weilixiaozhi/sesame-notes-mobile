import '../../l10n/app_localizations.dart';

/// 备忘本、导入和恢复预览共用本子类型文案，不依赖业务页面。
String memoTypeLabel(AppLocalizations l, String type) => switch (type) {
  'credentials' => l.memoCredentials,
  _ => l.memoNormal,
};
