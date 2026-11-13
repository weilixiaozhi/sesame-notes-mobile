import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/memo_media_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';

/// 正文图片的 Quill 嵌入构建器；未知格式由编辑器统一兜底，不影响其他段落。
class MemoImageEmbedBuilder extends EmbedBuilder {
  const MemoImageEmbedBuilder();

  @override
  String get key => 'memo_image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final data = embedContext.node.value.data;
    return MemoImageEmbed(mediaId: data is String ? data : '');
  }
}

/// 正文中的一张内联图片：按可用宽度等比展示，缺失时保留明确占位。
class MemoImageEmbed extends ConsumerWidget {
  const MemoImageEmbed({super.key, required this.mediaId});

  final String mediaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 编辑器左右各留 16 间距，图片不超过正文可用宽度。
    final available = (MediaQuery.sizeOf(context).width - AppDimens.p32).clamp(
      120.0,
      1600.0,
    );
    final bytes = ref.watch(memoMediaBytesProvider(mediaId));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: SizedBox(
          width: available,
          child: bytes.when(
            data: (value) => value == null || value.isEmpty
                ? _placeholder(context, failed: true)
                : Image.memory(
                    value,
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    gaplessPlayback: true,
                    // 按展示尺寸降采样解码，避免多张原图同时占用大块内存。
                    cacheWidth:
                        (available * MediaQuery.devicePixelRatioOf(context))
                            .round(),
                    semanticLabel: AppLocalizations.of(context).memoImageLabel,
                  ),
            loading: () => _placeholder(context, failed: false),
            error: (_, _) => _placeholder(context, failed: true),
          ),
        ),
      ),
    );
  }

  /// 加载中与失败共用同一尺寸，避免正文在图片就绪后跳动。
  Widget _placeholder(BuildContext context, {required bool failed}) {
    return Container(
      height: 96,
      alignment: Alignment.center,
      color: AppTokens.surfaceSecondary(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!failed)
            const SizedBox(
              width: AppDimens.icon20,
              height: AppDimens.icon20,
              child: CircularProgressIndicator(
                strokeWidth: AppDimens.progressStrokeWidth,
              ),
            )
          else
            Icon(
              AppIcons.imageOff,
              size: AppDimens.icon20,
              color: AppTokens.iconSecondary(context),
            ),
          if (failed) ...[
            const SizedBox(height: AppDimens.p8),
            Text(
              AppLocalizations.of(context).memoImageUnavailable,
              style: TextStyle(color: AppTokens.iconSecondary(context)),
            ),
          ],
        ],
      ),
    );
  }
}
