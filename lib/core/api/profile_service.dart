import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 云账号个人资料服务：只封装生成客户端、格式映射与错误日志。
///
/// 设计意图：不复制 DTO、不增加接口层级；所有网络调用 try-catch 收口，
/// 日志记录 action 与 request id，不记录密码、Token 或完整手机号。
class ProfileService {
  final SesameApiClient client;

  ProfileService(this.client);

  /// 读取当前本人资料（完整字段）。
  Future<CloudProfile> getMe() async {
    try {
      final resp = await ProfileApi(
        client.dio,
        client.serializers,
      ).getProfileMe();
      final data = resp.data;
      if (data == null) throw const FormatException('资料响应为空');
      return _toProfile(data);
    } catch (error, stackTrace) {
      logger.error('ProfileService', '读取本人资料失败', error, stackTrace);
      rethrow;
    }
  }

  /// 归一化头像 URL：服务端返回相对路径（同源部署），
  /// 客户端按 baseUrl 解析为绝对地址；绝对 URL 原样保留。
  String? _absoluteAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.hasScheme) return url;
    return Uri.parse(
      client.dio.options.baseUrl,
    ).resolve(uri.toString()).toString();
  }

  /// 更新昵称（trim 后 1-64，服务端校验换行与控制字符）。
  Future<CloudProfile> updateDisplayName(String displayName) async {
    try {
      final resp = await ProfileApi(client.dio, client.serializers)
          .patchProfileMe(
            patchProfileMeRequest: PatchProfileMeRequest(
              (b) => b..displayName = displayName.trim(),
            ),
          );
      final data = resp.data;
      if (data == null) throw const FormatException('资料更新响应为空');
      return _toProfile(data);
    } catch (error, stackTrace) {
      logger.error('ProfileService', '更新昵称失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新性别（UNSPECIFIED/MALE/FEMALE）。
  Future<CloudProfile> updateGender(String gender) async {
    try {
      final resp = await ProfileApi(client.dio, client.serializers)
          .patchProfileMe(
            patchProfileMeRequest: PatchProfileMeRequest(
              (b) => b..gender = gender,
            ),
          );
      final data = resp.data;
      if (data == null) throw const FormatException('资料更新响应为空');
      return _toProfile(data);
    } catch (error, stackTrace) {
      logger.error('ProfileService', '更新性别失败', error, stackTrace);
      rethrow;
    }
  }

  /// 上传头像（JSON Base64 契约）；成功返回最新版本号与 URL。
  Future<({String url, int version})> uploadAvatar({
    required String contentType,
    required List<int> bytes,
  }) async {
    try {
      final resp = await ProfileApi(client.dio, client.serializers)
          .putProfileAvatar(
            putProfileAvatarRequest: PutProfileAvatarRequest(
              (b) => b
                ..contentType = _contentTypeEnum(contentType)
                ..dataBase64 = base64Encode(bytes),
            ),
          );
      final data = resp.data;
      if (data == null) throw const FormatException('头像上传响应为空');
      return (
        url: _absoluteAvatarUrl(data.avatarUrl)!,
        version: data.avatarVersion,
      );
    } catch (error, stackTrace) {
      logger.error('ProfileService', '上传头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 恢复默认头像（幂等 204）。
  Future<void> deleteAvatar() async {
    try {
      await ProfileApi(client.dio, client.serializers).deleteProfileAvatar();
    } catch (error, stackTrace) {
      logger.error('ProfileService', '恢复默认头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 下载指定用户头像（本人或共同账本成员）；不存在返回 null。
  /// 契约：接口返回原始图片字节，Uint8List 可直接用于 Image.memory。
  Future<List<int>?> downloadAvatar(String userId) async {
    try {
      final resp = await ProfileApi(
        client.dio,
        client.serializers,
      ).getProfileAvatarByUserId(userId: userId);
      final data = resp.data;
      if (data == null) return null;
      return data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      logger.error('ProfileService', '下载头像失败', error, error.stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      logger.error('ProfileService', '下载头像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 修改密码：当前密码校验通过后更新，其他设备 Refresh Token 被撤销。
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await AuthApi(client.dio, client.serializers).patchAuthPassword(
        patchAuthPasswordRequest: PatchAuthPasswordRequest(
          (b) => b
            ..currentPassword = currentPassword
            ..newPassword = newPassword,
        ),
      );
    } catch (error, stackTrace) {
      logger.error('ProfileService', '修改密码失败', error, stackTrace);
      rethrow;
    }
  }

  /// 把 MIME 字符串映射为生成客户端的枚举；仅支持契约声明的三种类型。
  PutProfileAvatarRequestContentTypeEnum _contentTypeEnum(String contentType) {
    switch (contentType) {
      case 'image/png':
        return PutProfileAvatarRequestContentTypeEnum.imageSlashPng;
      case 'image/jpeg':
        return PutProfileAvatarRequestContentTypeEnum.imageSlashJpeg;
      case 'image/webp':
        return PutProfileAvatarRequestContentTypeEnum.imageSlashWebp;
    }
    throw ArgumentError.value(contentType, 'contentType', '不支持的图片类型');
  }

  /// 把生成客户端的本人资料响应映射为缓存模型。
  CloudProfile _toProfile(GetProfileMe200Response data) {
    return CloudProfile(
      userId: data.userId,
      sesameNumber: data.sesameNumber,
      displayName: data.displayName,
      avatarUrl: _absoluteAvatarUrl(data.avatarUrl),
      avatarVersion: data.avatarVersion,
      phone: data.phone,
      phoneMasked: data.phoneMasked,
      gender: data.gender.name,
    );
  }
}
