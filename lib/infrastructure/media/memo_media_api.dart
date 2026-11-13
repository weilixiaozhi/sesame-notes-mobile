import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 备忘录图片的上传与下载；认证沿用生成客户端声明的 bearer 标记。
class MemoMediaApi {
  MemoMediaApi(this.dio);

  final Dio dio;

  static const _secure = {
    'secure': [
      {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
    ],
  };

  bool get configured => dio.options.baseUrl.isNotEmpty;

  /// 上传幂等：服务端按标识与内容摘要返回同一元数据。
  Future<void> upload({
    required String id,
    required String mime,
    required Uint8List bytes,
  }) async {
    await dio.put<Map<String, dynamic>>(
      '/api/v1/memo-media/$id',
      data: {'content_type': mime, 'data_base64': base64Encode(bytes)},
      options: Options(
        contentType: Headers.jsonContentType,
        receiveTimeout: const Duration(seconds: 20),
        extra: _secure,
      ),
    );
  }

  /// 下载本人图片字节；服务端不存在时返回 null，其他错误交由上层记录。
  Future<Uint8List?> download(String id) async {
    try {
      final response = await dio.get<List<int>>(
        '/api/v1/memo-media/$id',
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 30),
          extra: _secure,
        ),
      );
      final data = response.data;
      return data == null ? null : Uint8List.fromList(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
