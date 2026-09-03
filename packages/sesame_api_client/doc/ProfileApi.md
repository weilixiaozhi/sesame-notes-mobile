# sesame_api_client.api.ProfileApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteProfileAvatar**](ProfileApi.md#deleteprofileavatar) | **DELETE** /api/v1/profile/avatar | 
[**getProfileAvatarByUserId**](ProfileApi.md#getprofileavatarbyuserid) | **GET** /api/v1/profile/avatar/{user_id} | 
[**getProfileMe**](ProfileApi.md#getprofileme) | **GET** /api/v1/profile/me | 
[**patchProfileMe**](ProfileApi.md#patchprofileme) | **PATCH** /api/v1/profile/me | 
[**putProfileAvatar**](ProfileApi.md#putprofileavatar) | **PUT** /api/v1/profile/avatar | 


# **deleteProfileAvatar**
> deleteProfileAvatar()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getProfileApi();

try {
    api.deleteProfileAvatar();
} on DioException catch (e) {
    print('Exception when calling ProfileApi->deleteProfileAvatar: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProfileAvatarByUserId**
> Uint8List getProfileAvatarByUserId(userId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getProfileApi();
final String userId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getProfileAvatarByUserId(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->getProfileAvatarByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**Uint8List**](Uint8List.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: image/png, image/jpeg, image/webp, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getProfileMe**
> GetProfileMe200Response getProfileMe()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getProfileApi();

try {
    final response = api.getProfileMe();
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->getProfileMe: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetProfileMe200Response**](GetProfileMe200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchProfileMe**
> GetProfileMe200Response patchProfileMe(patchProfileMeRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getProfileApi();
final PatchProfileMeRequest patchProfileMeRequest = ; // PatchProfileMeRequest | 

try {
    final response = api.patchProfileMe(patchProfileMeRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->patchProfileMe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **patchProfileMeRequest** | [**PatchProfileMeRequest**](PatchProfileMeRequest.md)|  | 

### Return type

[**GetProfileMe200Response**](GetProfileMe200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **putProfileAvatar**
> PutProfileAvatar200Response putProfileAvatar(putProfileAvatarRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getProfileApi();
final PutProfileAvatarRequest putProfileAvatarRequest = ; // PutProfileAvatarRequest | 

try {
    final response = api.putProfileAvatar(putProfileAvatarRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ProfileApi->putProfileAvatar: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **putProfileAvatarRequest** | [**PutProfileAvatarRequest**](PutProfileAvatarRequest.md)|  | 

### Return type

[**PutProfileAvatar200Response**](PutProfileAvatar200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

