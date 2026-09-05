# sesame_api_client.api.SystemApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getHealth**](SystemApi.md#gethealth) | **GET** /api/v1/health | 
[**getHealthReady**](SystemApi.md#gethealthready) | **GET** /api/v1/health/ready | 


# **getHealth**
> GetHealth200Response getHealth()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSystemApi();

try {
    final response = api.getHealth();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->getHealth: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetHealth200Response**](GetHealth200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getHealthReady**
> GetHealth200Response getHealthReady()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSystemApi();

try {
    final response = api.getHealthReady();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SystemApi->getHealthReady: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetHealth200Response**](GetHealth200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

