import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/memo_delta.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/memo_media_providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';

/// 正文图片被点击时交给页面处理的操作入口。
typedef MemoImageTapCallback =
    Future<void> Function(
      MemoImageRef image,
      Embed node,
      QuillController controller,
    );

/// 找到嵌入节点在文档中的字符偏移；行尾换行由行本身贡献，不能计入叶子长度。
int? memoImageEmbedIndex(Document document, Embed target) {
  var offset = 0;
  for (final node in document.root.children) {
    final line = node as Line;
    for (final child in line.children) {
      if (identical(child, target)) return offset;
      offset += child.length;
    }
    offset += 1;
  }
  return null;
}

/// 正文图片的 Quill 嵌入构建器；未知格式由编辑器统一兜底，不影响其他段落。
class MemoImageEmbedBuilder extends EmbedBuilder {
  const MemoImageEmbedBuilder({required this.onTap});

  final MemoImageTapCallback onTap;

  @override
  String get key => 'memo_image';

  /// 图片作为行内占位参与文本排版，行高由图片高度决定，光标不会落在图片上。
  @override
  bool get expanded => false;

  @override
  WidgetSpan buildWidgetSpan(Widget widget) =>
      WidgetSpan(alignment: PlaceholderAlignment.middle, child: widget);

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    return MemoImageEmbed(
      image: memoImageRefOf(embedContext.node.value.data),
      node: embedContext.node,
      controller: embedContext.controller,
      readOnly: embedContext.readOnly,
      onTap: onTap,
    );
  }
}

/// 正文中的一张内联图片：按引用比例展示，缺失时保留明确占位。
class MemoImageEmbed extends ConsumerWidget {
  const MemoImageEmbed({
    super.key,
    required this.image,
    required this.node,
    required this.controller,
    required this.readOnly,
    required this.onTap,
  });

  final MemoImageRef? image;
  final Embed node;
  final QuillController controller;
  final bool readOnly;
  final MemoImageTapCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = image;
    if (media == null) return _placeholder(context, failed: true, width: 160);
    // 编辑器左右各留 16 间距，图片按正文可用宽度的百分比展示。
    final available = (MediaQuery.sizeOf(context).width - AppDimens.p32).clamp(
      120.0,
      1600.0,
    );
    final width = available * media.percent / 100;
    final bytes = ref.watch(memoMediaBytesProvider(media.id));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p4),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(media, node, controller),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          child: SizedBox(
            width: width,
            child: bytes.when(
              data: (value) => value == null || value.isEmpty
                  ? _placeholder(context, failed: true, width: width)
                  : Image.memory(
                      value,
                      width: width,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      gaplessPlayback: true,
                      // 按展示尺寸降采样解码，避免多张原图同时占用大块内存。
                      cacheWidth:
                          (width * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      semanticLabel: AppLocalizations.of(
                        context,
                      ).memoImageLabel,
                    ),
              loading: () => _placeholder(context, failed: false, width: width),
              error: (_, _) =>
                  _placeholder(context, failed: true, width: width),
            ),
          ),
        ),
      ),
    );
  }

  /// 加载中与失败共用同一尺寸，避免正文在图片就绪后跳动。
  Widget _placeholder(
    BuildContext context, {
    required bool failed,
    required double width,
  }) {
    return Container(
      height: 96,
      width: width,
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
