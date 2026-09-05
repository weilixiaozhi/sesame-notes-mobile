import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for ImportsApi
void main() {
  final instance = SesameApiClient().getImportsApi();

  group(ImportsApi, () {
    //Future<PostLedgersByLedgerIdImports200Response> postLedgersByLedgerIdImports(String ledgerId, PostLedgersByLedgerIdImportsRequest postLedgersByLedgerIdImportsRequest, { String idempotencyKey }) async
    test('test postLedgersByLedgerIdImports', () async {
      // TODO
    });
  });
}
