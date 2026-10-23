/// 从 WebDAV SDK 的 HTTP 异常中读取状态码，不把传输错误当作目录不存在。
int? webDavStatusCode(Object error) {
  try {
    final response = (error as dynamic).response;
    return response == null ? null : (response as dynamic).statusCode as int?;
  } catch (_) {
    return null;
  }
}
