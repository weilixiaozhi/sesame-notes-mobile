import 'package:sesame_notes/data/models/accounting_records.dart';

/// 金额转换只需要本位币与有效汇率，不获得组合仓储的其他写入能力。
abstract interface class CurrencyRateRepository {
  /// 读取已存在账本的本位币。
  Future<String> ledgerBaseCurrency(String ledgerId);

  /// 读取对应本位币的最新自动汇率。
  Future<List<ExchangeRateSnapshot>> getLatestAutoRates(String base);

  /// 读取优先于自动汇率的人工覆盖。
  Future<List<ExchangeRateOverrideSnapshot>> getOverrides(String base);
}
