# sesame_api_client.api.CategoriesApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteLedgersByLedgerIdCategoriesByCategoryId**](CategoriesApi.md#deleteledgersbyledgeridcategoriesbycategoryid) | **DELETE** /api/v1/ledgers/{ledger_id}/categories/{category_id} | 
[**getLedgersByLedgerIdCategories**](CategoriesApi.md#getledgersbyledgeridcategories) | **GET** /api/v1/ledgers/{ledger_id}/categories | 
[**patchLedgersByLedgerIdCategoriesByCategoryId**](CategoriesApi.md#patchledgersbyledgeridcategoriesbycategoryid) | **PATCH** /api/v1/ledgers/{ledger_id}/categories/{category_id} | 
[**postLedgersByLedgerIdCategories**](CategoriesApi.md#postledgersbyledgeridcategories) | **POST** /api/v1/ledgers/{ledger_id}/categories | 


# **deleteLedgersByLedgerIdCategoriesByCategoryId**
> deleteLedgersByLedgerIdCategoriesByCategoryId(ledgerId, categoryId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getCategoriesApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String categoryId = 056cf10d-2d59-599c-9d97-6749e866aa52; // String | 

try {
    api.deleteLedgersByLedgerIdCategoriesByCategoryId(ledgerId, categoryId);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->deleteLedgersByLedgerIdCategoriesByCategoryId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **categoryId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdCategories**
> BuiltList<Category> getLedgersByLedgerIdCategories(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getCategoriesApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getLedgersByLedgerIdCategories(ledgerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->getLedgersByLedgerIdCategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

[**BuiltList&lt;Category&gt;**](Category.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchLedgersByLedgerIdCategoriesByCategoryId**
> Category patchLedgersByLedgerIdCategoriesByCategoryId(ledgerId, categoryId, patchLedgersByLedgerIdCategoriesByCategoryIdRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getCategoriesApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String categoryId = 056cf10d-2d59-599c-9d97-6749e866aa52; // String | 
final PatchLedgersByLedgerIdCategoriesByCategoryIdRequest patchLedgersByLedgerIdCategoriesByCategoryIdRequest = ; // PatchLedgersByLedgerIdCategoriesByCategoryIdRequest | 

try {
    final response = api.patchLedgersByLedgerIdCategoriesByCategoryId(ledgerId, categoryId, patchLedgersByLedgerIdCategoriesByCategoryIdRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->patchLedgersByLedgerIdCategoriesByCategoryId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **categoryId** | **String**|  | 
 **patchLedgersByLedgerIdCategoriesByCategoryIdRequest** | [**PatchLedgersByLedgerIdCategoriesByCategoryIdRequest**](PatchLedgersByLedgerIdCategoriesByCategoryIdRequest.md)|  | 

### Return type

[**Category**](Category.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postLedgersByLedgerIdCategories**
> Category postLedgersByLedgerIdCategories(ledgerId, postLedgersByLedgerIdCategoriesRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getCategoriesApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PostLedgersByLedgerIdCategoriesRequest postLedgersByLedgerIdCategoriesRequest = ; // PostLedgersByLedgerIdCategoriesRequest | 

try {
    final response = api.postLedgersByLedgerIdCategories(ledgerId, postLedgersByLedgerIdCategoriesRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CategoriesApi->postLedgersByLedgerIdCategories: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **postLedgersByLedgerIdCategoriesRequest** | [**PostLedgersByLedgerIdCategoriesRequest**](PostLedgersByLedgerIdCategoriesRequest.md)|  | 

### Return type

[**Category**](Category.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

