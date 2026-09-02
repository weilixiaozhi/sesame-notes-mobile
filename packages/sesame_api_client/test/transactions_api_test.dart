import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for TransactionsApi
void main() {
  final instance = SesameApiClient().getTransactionsApi();

  group(TransactionsApi, () {
    //Future deleteLedgersByLedgerIdTransactionsByTransactionId(String ledgerId, String transactionId, DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest deleteLedgersByLedgerIdTransactionsByTransactionIdRequest) async
    test('test deleteLedgersByLedgerIdTransactionsByTransactionId', () async {
      // TODO
    });

    //Future<GetLedgersByLedgerIdTransactions200Response> getLedgersByLedgerIdTransactions(String ledgerId, { int limit, String cursor }) async
    test('test getLedgersByLedgerIdTransactions', () async {
      // TODO
    });

    //Future<Transaction> patchLedgersByLedgerIdTransactionsByTransactionId(String ledgerId, String transactionId, PatchLedgersByLedgerIdTransactionsByTransactionIdRequest patchLedgersByLedgerIdTransactionsByTransactionIdRequest) async
    test('test patchLedgersByLedgerIdTransactionsByTransactionId', () async {
      // TODO
    });

    //Future<Transaction> postLedgersByLedgerIdTransactions(String ledgerId, PostLedgersByLedgerIdTransactionsRequest postLedgersByLedgerIdTransactionsRequest, { String idempotencyKey }) async
    test('test postLedgersByLedgerIdTransactions', () async {
      // TODO
    });
  });
}
