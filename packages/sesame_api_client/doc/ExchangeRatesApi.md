# sesame_api_client.api.ExchangeRatesApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getExchangeRates**](ExchangeRatesApi.md#getexchangerates) | **GET** /api/v1/exchange-rates | 


# **getExchangeRates**
> GetExchangeRates200Response getExchangeRates(base_)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getExchangeRatesApi();
final String base_ = base__example; // String | 

try {
    final response = api.getExchangeRates(base_);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ExchangeRatesApi->getExchangeRates: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **base_** | **String**|  | 

### Return type

[**GetExchangeRates200Response**](GetExchangeRates200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

