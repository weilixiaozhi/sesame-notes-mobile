// 真机相册权限冒烟：Android 上 image_picker 走系统 Photo Picker /
// ACTION_GET_CONTENT，无需 READ_MEDIA_IMAGES 等权限声明。
//
// 时序配合：本测试打印 GALLERY_PICKER_OPEN_MARKER 后打开系统相册；宿主机
// 脚本轮询 logcat 检测到标记后：① 检查前台 activity（证明无权限对话框）；
// ② 截图留证；③ 发送 BACK 模拟用户取消。
//
// 断言：打开与取消全程无平台/权限异常；返回 null（取消）不是错误。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('相册选择：无权限异常；打开后取消返回 null（取消非错误）', () async {
    // 宿主机脚本监听此标记：检查前台 → 截图 → 发送 BACK（模拟取消）
    // ignore: avoid_print
    print('GALLERY_PICKER_OPEN_MARKER');
    final picker = ImagePicker();
    XFile? result;
    Object? error;
    try {
      result = await picker
          .pickImage(
            source: ImageSource.gallery,
            maxWidth: 2048,
            maxHeight: 2048,
            imageQuality: 85,
          )
          .timeout(const Duration(seconds: 90));
    } catch (e) {
      error = e;
      // ignore: avoid_print
      print('GALLERY_PICKER_ERROR: $e');
    }
    expect(error, isNull, reason: 'Android 相册选择不得抛权限/平台异常（Photo Picker 无需权限）');
    // null = 用户取消（宿主机脚本已发送 BACK）；取消不是错误
    // ignore: avoid_print
    print('GALLERY_PICKER_RESULT: ${result?.name ?? 'null(取消)'}');
  });
}
