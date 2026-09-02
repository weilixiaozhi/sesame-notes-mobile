import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for CategoriesApi
void main() {
  final instance = SesameApiClient().getCategoriesApi();

  group(CategoriesApi, () {
    //Future deleteLedgersByLedgerIdCategoriesByCategoryId(String ledgerId, String categoryId) async
    test('test deleteLedgersByLedgerIdCategoriesByCategoryId', () async {
      // TODO
    });

    //Future<BuiltList<Category>> getLedgersByLedgerIdCategories(String ledgerId) async
    test('test getLedgersByLedgerIdCategories', () async {
      // TODO
    });

    //Future<Category> patchLedgersByLedgerIdCategoriesByCategoryId(String ledgerId, String categoryId, PatchLedgersByLedgerIdCategoriesByCategoryIdRequest patchLedgersByLedgerIdCategoriesByCategoryIdRequest) async
    test('test patchLedgersByLedgerIdCategoriesByCategoryId', () async {
      // TODO
    });

    //Future<Category> postLedgersByLedgerIdCategories(String ledgerId, PostLedgersByLedgerIdCategoriesRequest postLedgersByLedgerIdCategoriesRequest) async
    test('test postLedgersByLedgerIdCategories', () async {
      // TODO
    });
  });
}
