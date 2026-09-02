import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for ExchangeRatesApi
void main() {
  final instance = SesameApiClient().getExchangeRatesApi();

  group(ExchangeRatesApi, () {
    //Future<GetExchangeRates200Response> getExchangeRates(String base_) async
    test('test getExchangeRates', () async {
      // TODO
    });
  });
}
