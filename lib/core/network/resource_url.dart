/// 将服务端相对资源路径解析为绝对地址，完整 URI 保持原样。
String? resolveResourceUrl(String baseUrl, String? value) {
  if (value == null || value.isEmpty) return null;
  final resource = Uri.tryParse(value);
  if (resource == null || resource.hasScheme) return value;
  final base = Uri.tryParse(baseUrl);
  if (base == null) throw const FormatException('服务端资源地址无效');
  return base.resolveUri(resource).toString();
}
