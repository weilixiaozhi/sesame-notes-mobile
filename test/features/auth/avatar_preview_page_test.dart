import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/features/auth/presentation/avatar_preview_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/mine_page_header.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class _AuthenticatedAccountStateNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(userId: 'user-1', displayName: '芝麻仔382716'),
  );
}

void main() {
  /// 以设计稿手机视口渲染头像预览页。
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountStateProvider.overrideWith(
            _AuthenticatedAccountStateNotifier.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AvatarPreviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('头像预览页：顶部为文字关闭与标题，底部为相册和恢复默认操作', (tester) async {
    await pumpPage(tester);

    expect(find.text('关闭'), findsOneWidget);
    expect(find.text('头像'), findsOneWidget);
    expect(find.byIcon(AppIcons.close), findsNothing);
    expect(find.text('从相册选择'), findsOneWidget);
    expect(find.byIcon(AppIcons.camera), findsOneWidget);
    expect(find.text('恢复默认头像'), findsOneWidget);
    expect(find.byIcon(AppIcons.refresh), findsNothing);

    final galleryButton = tester.getRect(
      find.widgetWithText(FilledButton, '从相册选择'),
    );
    final restoreButton = tester.getRect(
      find.widgetWithText(FilledButton, '恢复默认头像'),
    );
    expect(galleryButton.height, 54);
    expect(restoreButton.height, 54);
    expect(restoreButton.top - galleryButton.bottom, 12);
  });

  testWidgets('无云头像时使用项目默认头像资源并居中显示为 260 方形', (tester) async {
    await pumpPage(tester);

    final assetImage = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == kDefaultAvatarAsset,
    );
    expect(assetImage, findsOneWidget);

    final imageRect = tester.getRect(assetImage);
    expect(imageRect.width, 260);
    expect(imageRect.height, 260);
    expect(imageRect.center.dx, 195);
  });
}
