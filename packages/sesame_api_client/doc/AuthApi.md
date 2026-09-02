# sesame_api_client.api.AuthApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**patchAuthPassword**](AuthApi.md#patchauthpassword) | **PATCH** /api/v1/auth/password | 
[**postAuthLogin**](AuthApi.md#postauthlogin) | **POST** /api/v1/auth/login | 
[**postAuthLogout**](AuthApi.md#postauthlogout) | **POST** /api/v1/auth/logout | 
[**postAuthRefresh**](AuthApi.md#postauthrefresh) | **POST** /api/v1/auth/refresh | 
[**postAuthRegister**](AuthApi.md#postauthregister) | **POST** /api/v1/auth/register | 


# **patchAuthPassword**
> patchAuthPassword(patchAuthPasswordRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAuthApi();
final PatchAuthPasswordRequest patchAuthPasswordRequest = ; // PatchAuthPasswordRequest | 

try {
    api.patchAuthPassword(patchAuthPasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->patchAuthPassword: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **patchAuthPasswordRequest** | [**PatchAuthPasswordRequest**](PatchAuthPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postAuthLogin**
> PostAuthRegister201Response postAuthLogin(postAuthLoginRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAuthApi();
final PostAuthLoginRequest postAuthLoginRequest = ; // PostAuthLoginRequest | 

try {
    final response = api.postAuthLogin(postAuthLoginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->postAuthLogin: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postAuthLoginRequest** | [**PostAuthLoginRequest**](PostAuthLoginRequest.md)|  | 

### Return type

[**PostAuthRegister201Response**](PostAuthRegister201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postAuthLogout**
> postAuthLogout(postAuthRefreshRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAuthApi();
final PostAuthRefreshRequest postAuthRefreshRequest = ; // PostAuthRefreshRequest | 

try {
    api.postAuthLogout(postAuthRefreshRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->postAuthLogout: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postAuthRefreshRequest** | [**PostAuthRefreshRequest**](PostAuthRefreshRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postAuthRefresh**
> PostAuthRegister201Response postAuthRefresh(postAuthRefreshRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAuthApi();
final PostAuthRefreshRequest postAuthRefreshRequest = ; // PostAuthRefreshRequest | 

try {
    final response = api.postAuthRefresh(postAuthRefreshRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->postAuthRefresh: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postAuthRefreshRequest** | [**PostAuthRefreshRequest**](PostAuthRefreshRequest.md)|  | 

### Return type

[**PostAuthRegister201Response**](PostAuthRegister201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postAuthRegister**
> PostAuthRegister201Response postAuthRegister(postAuthRegisterRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAuthApi();
final PostAuthRegisterRequest postAuthRegisterRequest = ; // PostAuthRegisterRequest | 

try {
    final response = api.postAuthRegister(postAuthRegisterRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->postAuthRegister: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postAuthRegisterRequest** | [**PostAuthRegisterRequest**](PostAuthRegisterRequest.md)|  | 

### Return type

[**PostAuthRegister201Response**](PostAuthRegister201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

