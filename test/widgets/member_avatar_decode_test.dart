import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/providers/avatar_providers.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/widgets/avatar_image.dart';

import '../helpers/test_isolation.dart';

/// 原生读取与解码在真实事件循环完成，界面回调由测试帧推进，两者都完成后检查实际像素。
Future<ImageInfo> _decodedAvatar(WidgetTester tester) async {
  final elapsed = Stopwatch()..start();
  while (elapsed.elapsed < const Duration(seconds: 5)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
    final raw = tester.widget<RawImage>(find.byType(RawImage).last);
    if (raw.image != null) return ImageInfo(image: raw.image!.clone());
  }
  throw TestFailure('头像未在 5 秒内完成实际界面解码');
}

/// 头像只按实际显示像素解码，相同原图仍能供更大预览重新取得足够像素。
void main() {
  for (final local in [false, true]) {
    testWidgets('${local ? '成员文件' : '默认素材'}小头像按设备像素解码并保留布局尺寸', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetDevicePixelRatio);
      ImageInfo? decoded;
      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              memberAvatarPathProvider((
                userId: 'member',
                version: 1,
                hasAvatar: true,
              )).overrideWith(
                (_) async => File(kDefaultAvatarAsset).absolute.path,
              ),
            ],
            child: MaterialApp(
              home: Center(
                child: MemberAvatar(
                  userId: local ? 'member' : null,
                  version: 1,
                  hasAvatar: true,
                  size: 22,
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final source =
            (tester.widget<Image>(find.byType(Image).last).image as AvatarImage)
                .source;
        expect(source, local ? isA<FileImage>() : isA<AssetImage>());
        decoded = await _decodedAvatar(tester);
        expect(decoded.image.width, 66);
        expect(decoded.image.height, 66);
        expect(tester.getSize(find.byType(ClipOval)), const Size.square(22));
      } catch (error, stack) {
        debugPrint('头像解码尺寸检查失败：$error\n$stack');
        rethrow;
      } finally {
        decoded?.dispose();
        await tester.pumpWidget(const SizedBox.shrink());
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
        await tester.pump();
      }
    });
  }

  testWidgets('非方形头像保持长宽比，覆盖裁切的短边仍有足够像素', (tester) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    Directory? root;
    ImageInfo? decoded;
    try {
      final path = (await tester.runAsync(() async {
        root = await createTestTempDirectory('avatar-decode-');
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(Colors.blue, BlendMode.src);
        final picture = recorder.endRecording();
        final image = await picture.toImage(1024, 512);
        try {
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!;
          final file = File('${root!.path}${Platform.pathSeparator}avatar.png');
          await file.writeAsBytes(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          );
          return file.path;
        } finally {
          image.dispose();
          picture.dispose();
        }
      }))!;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberAvatarPathProvider((
              userId: 'landscape',
              version: 1,
              hasAvatar: true,
            )).overrideWith((_) async => path),
          ],
          child: const MaterialApp(
            home: Center(
              child: MemberAvatar(
                userId: 'landscape',
                version: 1,
                hasAvatar: true,
                size: 22,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      decoded = await _decodedAvatar(tester);
      expect(decoded.image.width, 132);
      expect(decoded.image.height, 66);
      expect(tester.getSize(find.byType(ClipOval)), const Size.square(22));
    } catch (error, stack) {
      debugPrint('非方头像解码检查失败：$error\n$stack');
      rethrow;
    } finally {
      decoded?.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await tester.pump();
      if (root != null) {
        await tester.runAsync(() => root!.delete(recursive: true));
      }
    }
  });
}
