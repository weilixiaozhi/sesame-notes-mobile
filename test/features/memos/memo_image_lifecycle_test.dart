import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_document.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_image.dart';

/// 构造实际可输出的多段落文档，不以超出图片预算作为取消的替代路径。
MemoDocument _document(int paragraphs) => MemoDocument(
  bookType: 'normal',
  body: {
    'ops': [
      {'insert': List.filled(paragraphs, '完整保留的笔记正文\n').join()},
    ],
  },
);

/// 记录引擎位图与绘图记录，测试结束必须恢复原有全局诊断钩子。
class _RenderResources {
  final previousImageCreate = ui.Image.onCreate;
  final previousImageDispose = ui.Image.onDispose;
  final previousPictureCreate = ui.Picture.onCreate;
  final previousPictureDispose = ui.Picture.onDispose;
  int imageCreates = 0,
      imageDisposes = 0,
      pictureCreates = 0,
      pictureDisposes = 0;

  /// 可在原生位图创建边界请求取消，验证编码前停止与资源释放。
  _RenderResources({void Function()? onImageCreated}) {
    ui.Image.onCreate = (image) {
      imageCreates++;
      previousImageCreate?.call(image);
      onImageCreated?.call();
    };
    ui.Image.onDispose = (image) {
      imageDisposes++;
      previousImageDispose?.call(image);
    };
    ui.Picture.onCreate = (picture) {
      pictureCreates++;
      previousPictureCreate?.call(picture);
    };
    ui.Picture.onDispose = (picture) {
      pictureDisposes++;
      previousPictureDispose?.call(picture);
    };
  }

  /// 防止测试间共享引擎诊断回调。
  void restore() {
    ui.Image.onCreate = previousImageCreate;
    ui.Image.onDispose = previousImageDispose;
    ui.Picture.onCreate = previousPictureCreate;
    ui.Picture.onDispose = previousPictureDispose;
  }
}

/// 取消不仅阻止文件交付，也应停止后续大内存分配并回收已有引擎资源。
void main() {
  testWidgets('排版期间收到取消时停止生成，未分配整图且随后仍可正常导出', (tester) async {
    await tester.runAsync(() async {
      // 先完成字体注册，后续取消必须实际经过排版的让出边界。
      await MemoImage.render(_document(1));
      var cancelled = false;
      final resources = _RenderResources();
      final cancelTimer = Timer(Duration.zero, () => cancelled = true);
      try {
        await expectLater(
          MemoImage.render(_document(160), isCancelled: () => cancelled),
          throwsA(isA<MemoImageCancelled>()),
        );
        expect(cancelled, isTrue);
        expect(resources.imageCreates, 0);
        expect(resources.pictureCreates, 0);
        final bytes = await MemoImage.render(_document(2));
        expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
        expect(resources.imageCreates, 1);
        expect(resources.imageDisposes, 1);
        expect(resources.pictureCreates, 1);
        expect(resources.pictureDisposes, 1);
      } catch (error, stack) {
        debugPrint('笔记图片排版取消检查失败：$error\n$stack');
        rethrow;
      } finally {
        cancelTimer.cancel();
        resources.restore();
      }
    });
  });

  testWidgets('位图已创建时取消仍释放位图和绘图记录', (tester) async {
    await tester.runAsync(() async {
      await MemoImage.render(_document(1));
      var cancelled = false;
      final resources = _RenderResources(
        onImageCreated: () => cancelled = true,
      );
      try {
        await expectLater(
          MemoImage.render(_document(2), isCancelled: () => cancelled),
          throwsA(isA<MemoImageCancelled>()),
        );
        expect(resources.imageCreates, 1);
        expect(resources.imageDisposes, 1);
        expect(resources.pictureCreates, 1);
        expect(resources.pictureDisposes, 1);
      } catch (error, stack) {
        debugPrint('笔记图片位图取消检查失败：$error\n$stack');
        rethrow;
      } finally {
        resources.restore();
      }
    });
  });
}
