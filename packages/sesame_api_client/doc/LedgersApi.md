# sesame_api_client.api.LedgersApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteLedgersByLedgerId**](LedgersApi.md#deleteledgersbyledgerid) | **DELETE** /api/v1/ledgers/{ledger_id} | 
[**getLedgers**](LedgersApi.md#getledgers) | **GET** /api/v1/ledgers | 
[**getLedgersByLedgerId**](LedgersApi.md#getledgersbyledgerid) | **GET** /api/v1/ledgers/{ledger_id} | 
[**patchLedgersByLedgerId**](LedgersApi.md#patchledgersbyledgerid) | **PATCH** /api/v1/ledgers/{ledger_id} | 
[**postLedgers**](LedgersApi.md#postledgers) | **POST** /api/v1/ledgers | 


# **deleteLedgersByLedgerId**
> deleteLedgersByLedgerId(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getLedgersApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    api.deleteLedgersByLedgerId(ledgerId);
} on DioException catch (e) {
    print('Exception when calling LedgersApi->deleteLedgersByLedgerId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgers**
> BuiltList<Ledger> getLedgers()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getLedgersApi();

try {
    final response = api.getLedgers();
    print(response);
} on DioException catch (e) {
    print('Exception when calling LedgersApi->getLedgers: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;Ledger&gt;**](Ledger.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerId**
> Ledger getLedgersByLedgerId(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getLedgersApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getLedgersByLedgerId(ledgerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LedgersApi->getLedgersByLedgerId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

[**Ledger**](Ledger.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchLedgersByLedgerId**
> Ledger patchLedgersByLedgerId(ledgerId, patchLedgersByLedgerIdRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getLedgersApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PatchLedgersByLedgerIdRequest patchLedgersByLedgerIdRequest = ; // PatchLedgersByLedgerIdRequest | 

try {
    final response = api.patchLedgersByLedgerId(ledgerId, patchLedgersByLedgerIdRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LedgersApi->patchLedgersByLedgerId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **patchLedgersByLedgerIdRequest** | [**PatchLedgersByLedgerIdRequest**](PatchLedgersByLedgerIdRequest.md)|  | 

### Return type

[**Ledger**](Ledger.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postLedgers**
> Ledger postLedgers(postLedgersRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getLedgersApi();
final PostLedgersRequest postLedgersRequest = ; // PostLedgersRequest | 

try {
    final response = api.postLedgers(postLedgersRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LedgersApi->postLedgers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postLedgersRequest** | [**PostLedgersRequest**](PostLedgersRequest.md)|  | 

### Return type

[**Ledger**](Ledger.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

