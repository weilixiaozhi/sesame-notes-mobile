import 'package:sesame_notes/core/logging/logger_service.dart';

/// 校验持久化或外部数据的业务类型，仅接受明确的支出标记。
String requireExpenseType(Object? value) {
  try {
    if (value != 'expense') {
      throw const FormatException('仅支持支出（expense），请检查数据类型');
    }
    return 'expense';
  } catch (error, stackTrace) {
    logger.error('ExpenseType', '业务类型校验失败 type=$value', error, stackTrace);
    rethrow;
  }
}
