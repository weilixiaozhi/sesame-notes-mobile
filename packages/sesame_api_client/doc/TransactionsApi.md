# sesame_api_client.api.TransactionsApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteLedgersByLedgerIdTransactionsByTransactionId**](TransactionsApi.md#deleteledgersbyledgeridtransactionsbytransactionid) | **DELETE** /api/v1/ledgers/{ledger_id}/transactions/{transaction_id} | 
[**getLedgersByLedgerIdTransactions**](TransactionsApi.md#getledgersbyledgeridtransactions) | **GET** /api/v1/ledgers/{ledger_id}/transactions | 
[**patchLedgersByLedgerIdTransactionsByTransactionId**](TransactionsApi.md#patchledgersbyledgeridtransactionsbytransactionid) | **PATCH** /api/v1/ledgers/{ledger_id}/transactions/{transaction_id} | 
[**postLedgersByLedgerIdTransactions**](TransactionsApi.md#postledgersbyledgeridtransactions) | **POST** /api/v1/ledgers/{ledger_id}/transactions | 


# **deleteLedgersByLedgerIdTransactionsByTransactionId**
> deleteLedgersByLedgerIdTransactionsByTransactionId(ledgerId, transactionId, deleteLedgersByLedgerIdTransactionsByTransactionIdRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getTransactionsApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String transactionId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest deleteLedgersByLedgerIdTransactionsByTransactionIdRequest = ; // DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest | 

try {
    api.deleteLedgersByLedgerIdTransactionsByTransactionId(ledgerId, transactionId, deleteLedgersByLedgerIdTransactionsByTransactionIdRequest);
} on DioException catch (e) {
    print('Exception when calling TransactionsApi->deleteLedgersByLedgerIdTransactionsByTransactionId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **transactionId** | **String**|  | 
 **deleteLedgersByLedgerIdTransactionsByTransactionIdRequest** | [**DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest**](DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdTransactions**
> GetLedgersByLedgerIdTransactions200Response getLedgersByLedgerIdTransactions(ledgerId, limit, cursor)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getTransactionsApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final int limit = 56; // int | 
final String cursor = cursor_example; // String | 

try {
    final response = api.getLedgersByLedgerIdTransactions(ledgerId, limit, cursor);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TransactionsApi->getLedgersByLedgerIdTransactions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **limit** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 

### Return type

[**GetLedgersByLedgerIdTransactions200Response**](GetLedgersByLedgerIdTransactions200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchLedgersByLedgerIdTransactionsByTransactionId**
> Transaction patchLedgersByLedgerIdTransactionsByTransactionId(ledgerId, transactionId, patchLedgersByLedgerIdTransactionsByTransactionIdRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getTransactionsApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String transactionId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PatchLedgersByLedgerIdTransactionsByTransactionIdRequest patchLedgersByLedgerIdTransactionsByTransactionIdRequest = ; // PatchLedgersByLedgerIdTransactionsByTransactionIdRequest | 

try {
    final response = api.patchLedgersByLedgerIdTransactionsByTransactionId(ledgerId, transactionId, patchLedgersByLedgerIdTransactionsByTransactionIdRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TransactionsApi->patchLedgersByLedgerIdTransactionsByTransactionId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **transactionId** | **String**|  | 
 **patchLedgersByLedgerIdTransactionsByTransactionIdRequest** | [**PatchLedgersByLedgerIdTransactionsByTransactionIdRequest**](PatchLedgersByLedgerIdTransactionsByTransactionIdRequest.md)|  | 

### Return type

[**Transaction**](Transaction.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postLedgersByLedgerIdTransactions**
> Transaction postLedgersByLedgerIdTransactions(ledgerId, postLedgersByLedgerIdTransactionsRequest, idempotencyKey)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getTransactionsApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PostLedgersByLedgerIdTransactionsRequest postLedgersByLedgerIdTransactionsRequest = ; // PostLedgersByLedgerIdTransactionsRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.postLedgersByLedgerIdTransactions(ledgerId, postLedgersByLedgerIdTransactionsRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling TransactionsApi->postLedgersByLedgerIdTransactions: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **postLedgersByLedgerIdTransactionsRequest** | [**PostLedgersByLedgerIdTransactionsRequest**](PostLedgersByLedgerIdTransactionsRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**Transaction**](Transaction.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

