import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 将三类私有同步的冻结原文适配为明确的生成联合类型，不改写持久化正文。
class SyncChangeCodec {
  /// 复用当前客户端的序列化器，保留生产注入的协议适配能力。
  SyncChangeCodec(this._serializers);

  final Serializers _serializers;

  /// 按日子实体及操作选择明确的生成联合分支，只读取冻结原文。
  PostSyncPushRequestChangesInner dayChangeFromFrozen(String frozen) {
    try {
      final wire = jsonDecode(frozen) as Map<String, dynamic>;
      if (wire['entity_type'] == 'day_book') {
        final variant = wire['action'] == 'delete'
            ? AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf1>(
                value: _deserialize(
                  frozen,
                  PostSyncPushRequestChangesInnerAnyOfAnyOf1.serializer,
                ),
              )
            : AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf>(
                value: _deserialize(
                  frozen,
                  PostSyncPushRequestChangesInnerAnyOfAnyOf.serializer,
                ),
              );
        return PostSyncPushRequestChangesInner(
          (b) => b
            ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf>(
              value: PostSyncPushRequestChangesInnerAnyOf(
                (b) => b..anyOf = variant,
              ),
            ),
        );
      }
      if (wire['entity_type'] != 'day_event') {
        throw const FormatException('冻结日子实体类型无效');
      }
      final variant = wire['action'] == 'delete'
          ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf1AnyOf1>(
              value: _deserialize(
                frozen,
                PostSyncPushRequestChangesInnerAnyOf1AnyOf1.serializer,
              ),
            )
          : AnyOf1<PostSyncPushRequestChangesInnerAnyOf1AnyOf>(
              value: _deserialize(
                frozen,
                PostSyncPushRequestChangesInnerAnyOf1AnyOf.serializer,
              ),
            );
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf1>(
            value: PostSyncPushRequestChangesInnerAnyOf1(
              (b) => b..anyOf = variant,
            ),
          ),
      );
    } catch (error, stackTrace) {
      logger.error(
        'SyncChangeCodec',
        '日子冻结请求协议转换失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 按备忘录本或笔记操作选择生成联合分支，正文交给注入序列化器校验。
  PostSyncPushRequestChangesInner memoChangeFromFrozen(String frozen) {
    try {
      final wire = jsonDecode(frozen) as Map<String, dynamic>;
      if (wire['entity_type'] == 'memo_book') {
        final variant = wire['action'] == 'delete'
            ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf9AnyOf1>(
                value: _deserialize(
                  frozen,
                  PostSyncPushRequestChangesInnerAnyOf9AnyOf1.serializer,
                ),
              )
            : AnyOf1<PostSyncPushRequestChangesInnerAnyOf9AnyOf>(
                value: _deserialize(
                  frozen,
                  PostSyncPushRequestChangesInnerAnyOf9AnyOf.serializer,
                ),
              );
        return PostSyncPushRequestChangesInner(
          (b) => b
            ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf9>(
              value: PostSyncPushRequestChangesInnerAnyOf9(
                (b) => b..anyOf = variant,
              ),
            ),
        );
      }
      if (wire['entity_type'] != 'memo_entry') {
        throw const FormatException('MEMO_ENTITY_TYPE');
      }
      final variant = wire['action'] == 'delete'
          ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf10AnyOf1>(
              value: _deserialize(
                frozen,
                PostSyncPushRequestChangesInnerAnyOf10AnyOf1.serializer,
              ),
            )
          : AnyOf1<PostSyncPushRequestChangesInnerAnyOf10AnyOf>(
              value: _deserialize(
                frozen,
                PostSyncPushRequestChangesInnerAnyOf10AnyOf.serializer,
              ),
            );
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf10>(
            value: PostSyncPushRequestChangesInnerAnyOf10(
              (b) => b..anyOf = variant,
            ),
          ),
      );
    } catch (error, stackTrace) {
      logger.error(
        'SyncChangeCodec',
        '备忘录冻结请求协议转换失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 按健身空间及四种内容类型选择生成联合分支，不处理业务归属。
  PostSyncPushRequestChangesInner fitnessChangeFromFrozen(String wire) {
    try {
      final values = jsonDecode(wire) as Map<String, dynamic>;
      final deleted = values['action'] == 'delete';
      // 明确选择每种实体的生成联合分支，避免自动匹配后无法正确序列化。
      final AnyOf entity = switch (values['entity_type']) {
        'fitness_space' => AnyOf1<PostSyncPushRequestChangesInnerAnyOf15>(
          value: PostSyncPushRequestChangesInnerAnyOf15(
            (b) => b
              ..anyOf = deleted
                  ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf15AnyOf1>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf15AnyOf1.serializer,
                      ),
                    )
                  : AnyOf1<PostSyncPushRequestChangesInnerAnyOf15AnyOf>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf15AnyOf.serializer,
                      ),
                    ),
          ),
        ),
        'fitness_template' => AnyOf1<PostSyncPushRequestChangesInnerAnyOf11>(
          value: PostSyncPushRequestChangesInnerAnyOf11(
            (b) => b
              ..anyOf = deleted
                  ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf11AnyOf1>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf11AnyOf1.serializer,
                      ),
                    )
                  : AnyOf1<PostSyncPushRequestChangesInnerAnyOf11AnyOf>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf11AnyOf.serializer,
                      ),
                    ),
          ),
        ),
        'fitness_plan' => AnyOf1<PostSyncPushRequestChangesInnerAnyOf12>(
          value: PostSyncPushRequestChangesInnerAnyOf12(
            (b) => b
              ..anyOf = deleted
                  ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf12AnyOf1>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf12AnyOf1.serializer,
                      ),
                    )
                  : AnyOf1<PostSyncPushRequestChangesInnerAnyOf12AnyOf>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf12AnyOf.serializer,
                      ),
                    ),
          ),
        ),
        'fitness_workout' => AnyOf1<PostSyncPushRequestChangesInnerAnyOf13>(
          value: PostSyncPushRequestChangesInnerAnyOf13(
            (b) => b
              ..anyOf = deleted
                  ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf13AnyOf1>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf13AnyOf1.serializer,
                      ),
                    )
                  : AnyOf1<PostSyncPushRequestChangesInnerAnyOf13AnyOf>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf13AnyOf.serializer,
                      ),
                    ),
          ),
        ),
        'fitness_preferences' => AnyOf1<PostSyncPushRequestChangesInnerAnyOf14>(
          value: PostSyncPushRequestChangesInnerAnyOf14(
            (b) => b
              ..anyOf = deleted
                  ? AnyOf1<PostSyncPushRequestChangesInnerAnyOf14AnyOf1>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf14AnyOf1.serializer,
                      ),
                    )
                  : AnyOf1<PostSyncPushRequestChangesInnerAnyOf14AnyOf>(
                      value: _deserialize(
                        wire,
                        PostSyncPushRequestChangesInnerAnyOf14AnyOf.serializer,
                      ),
                    ),
          ),
        ),
        _ => throw const FormatException('FITNESS_ENTITY_TYPE'),
      };
      return PostSyncPushRequestChangesInner((b) => b..anyOf = entity);
    } catch (error, stackTrace) {
      logger.error(
        'SyncChangeCodec',
        '健身冻结请求协议转换失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 使用指定生成类型反序列化，错误由各业务协议入口记录并原样上抛。
  T _deserialize<T>(String json, Serializer<T> serializer) =>
      _serializers.deserialize(
            jsonDecode(json),
            specifiedType: FullType(serializer.types.first),
          )
          as T;
}
