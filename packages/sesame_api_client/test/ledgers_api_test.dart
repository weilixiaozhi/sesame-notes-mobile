import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for LedgersApi
void main() {
  final instance = SesameApiClient().getLedgersApi();

  group(LedgersApi, () {
    //Future deleteLedgersByLedgerId(String ledgerId) async
    test('test deleteLedgersByLedgerId', () async {
      // TODO
    });

    //Future<BuiltList<Ledger>> getLedgers() async
    test('test getLedgers', () async {
      // TODO
    });

    //Future<Ledger> getLedgersByLedgerId(String ledgerId) async
    test('test getLedgersByLedgerId', () async {
      // TODO
    });

    //Future<Ledger> patchLedgersByLedgerId(String ledgerId, PatchLedgersByLedgerIdRequest patchLedgersByLedgerIdRequest) async
    test('test patchLedgersByLedgerId', () async {
      // TODO
    });

    //Future<Ledger> postLedgers(PostLedgersRequest postLedgersRequest) async
    test('test postLedgers', () async {
      // TODO
    });
  });
}
