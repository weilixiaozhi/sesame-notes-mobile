# sesame_api_client.api.ImportsApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**postLedgersByLedgerIdImports**](ImportsApi.md#postledgersbyledgeridimports) | **POST** /api/v1/ledgers/{ledger_id}/imports | 


# **postLedgersByLedgerIdImports**
> PostLedgersByLedgerIdImports200Response postLedgersByLedgerIdImports(ledgerId, postLedgersByLedgerIdImportsRequest, idempotencyKey)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getImportsApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PostLedgersByLedgerIdImportsRequest postLedgersByLedgerIdImportsRequest = ; // PostLedgersByLedgerIdImportsRequest | 
final String idempotencyKey = idempotencyKey_example; // String | 

try {
    final response = api.postLedgersByLedgerIdImports(ledgerId, postLedgersByLedgerIdImportsRequest, idempotencyKey);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ImportsApi->postLedgersByLedgerIdImports: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **postLedgersByLedgerIdImportsRequest** | [**PostLedgersByLedgerIdImportsRequest**](PostLedgersByLedgerIdImportsRequest.md)|  | 
 **idempotencyKey** | **String**|  | [optional] 

### Return type

[**PostLedgersByLedgerIdImports200Response**](PostLedgersByLedgerIdImports200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

