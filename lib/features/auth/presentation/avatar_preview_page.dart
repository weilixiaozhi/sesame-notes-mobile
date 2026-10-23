import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 头像预览/设置页：独立暗色全屏 Modal。
///
/// 提供「从相册选择」与「恢复默认头像」两项操作；
/// 权限拒绝、用户取消选择与网络失败均使用友好文案，取消选择不是错误；
/// 上传成功前不覆盖当前有效云头像；恢复默认先由服务端确认删除，再清本地缓存。
class AvatarPreviewPage extends ConsumerStatefulWidget {
  const AvatarPreviewPage({super.key});

  @override
  ConsumerState<AvatarPreviewPage> createState() => _AvatarPreviewPageState();
}

class _AvatarPreviewPageState extends ConsumerState<AvatarPreviewPage> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final foreground = AppTokens.mediaForeground.withValues(alpha: 0.9);
    final actionStyle = FilledButton.styleFrom(
      backgroundColor: AppTokens.mediaControlBackground,
      foregroundColor: AppTokens.mediaForeground,
      textStyle: AppTextTokens.title(context),
      disabledBackgroundColor: AppTokens.mediaControlDisabled,
      minimumSize: const Size.fromHeight(54),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
    );

    return Scaffold(
      backgroundColor: AppTokens.avatarPreviewBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: foreground,
                            textStyle: AppTextTokens.title(context),
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.avatarClose),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.avatarPreviewTitle,
                        textAlign: TextAlign.center,
                        style: AppTextTokens.title(
                          context,
                        ).copyWith(color: foreground),
                      ),
                    ),
                    const SizedBox(width: 64),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: AppDimens.avatarPreviewSize,
                  height: AppDimens.avatarPreviewSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTokens.mediaPlaceholder,
                    boxShadow: [
                      BoxShadow(
                        color: AppTokens.mediaShadow,
                        blurRadius: AppShadows.avatarBlur,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  // 本人头像统一走 SelfAvatar:磁盘缓存离线可用,
                  // 未上传头像/缓存未命中时回退全局默认头像资产。
                  child: const SelfAvatar(size: AppDimens.avatarPreviewSize),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p16,
                0,
                AppDimens.p16,
                AppDimens.p32,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: actionStyle,
                      onPressed: busy ? null : _pickFromGallery,
                      child: Row(
                        children: [
                          const Icon(AppIcons.camera, size: AppDimens.icon20),
                          const SizedBox(width: AppDimens.p12),
                          Text(l10n.avatarFromGallery),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: actionStyle.merge(
                        FilledButton.styleFrom(
                          foregroundColor: AppTokens.error(context),
                        ),
                      ),
                      onPressed: busy ? null : _restoreDefault,
                      child: Text(l10n.avatarRestoreDefault),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 从相册选择并上传：先压缩到服务端上限内，再上传；取消选择不是错误。
  Future<void> _pickFromGallery() async {
    final l10n = AppLocalizations.of(context);
    setState(() => busy = true);
    try {
      // 相册选择：压缩质量/像素上限是安全常量，不是产品画质承诺
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null || !mounted) return; // 用户取消选择：静默返回（非错误）
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      // 与服务端 MAX_AVATAR_BYTES 保持一致：超出后服务端会返回 413
      if (bytes.length > 8 * 1024 * 1024) {
        if (!mounted) return;
        showToast(context, l10n.avatarTooLarge);
        return;
      }
      final contentType = _guessContentType(image.name);
      if (contentType == null) {
        if (!mounted) return;
        showToast(context, l10n.avatarInvalid);
        return;
      }
      await ref
          .read(authActionsProvider)
          .uploadAvatar(contentType: contentType, bytes: bytes);
    } catch (error, stackTrace) {
      logger.error('AvatarPreview', '上传头像失败', error, stackTrace);
      if (!mounted) return;
      showToast(context, switch (mapApiError(error)) {
        ApiErrorKind.network => l10n.authErrorNetworkIssue,
        ApiErrorKind.server => l10n.authErrorServer,
        _ => l10n.avatarUploadFailed,
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 按文件名扩展名判断图片 MIME；仅支持契约声明的 PNG/JPEG/WebP。
  String? _guessContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return null;
  }

  /// 恢复默认头像：服务端确认删除后再清当前账号本地头像缓存。
  Future<void> _restoreDefault() async {
    final l10n = AppLocalizations.of(context);
    setState(() => busy = true);
    try {
      await ref.read(authActionsProvider).restoreDefaultAvatar();
      if (mounted) showToast(context, l10n.avatarRestored);
    } catch (error, stackTrace) {
      logger.error('AvatarPreview', '恢复默认头像失败', error, stackTrace);
      if (!mounted) return;
      showToast(context, switch (mapApiError(error)) {
        ApiErrorKind.network => l10n.authErrorNetworkIssue,
        ApiErrorKind.server => l10n.authErrorServer,
        _ => l10n.avatarUploadFailed,
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
