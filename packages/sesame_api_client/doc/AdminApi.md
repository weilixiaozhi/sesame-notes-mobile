# sesame_api_client.api.AdminApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteAdminUsersByUserIdDevicesByDeviceId**](AdminApi.md#deleteadminusersbyuseriddevicesbydeviceid) | **DELETE** /api/v1/admin/users/{user_id}/devices/{device_id} | 
[**getAdminAuditLogs**](AdminApi.md#getadminauditlogs) | **GET** /api/v1/admin/audit-logs | 
[**getAdminStatus**](AdminApi.md#getadminstatus) | **GET** /api/v1/admin/status | 
[**getAdminUsers**](AdminApi.md#getadminusers) | **GET** /api/v1/admin/users | 
[**patchAdminUsersByUserIdDisable**](AdminApi.md#patchadminusersbyuseriddisable) | **PATCH** /api/v1/admin/users/{user_id}/disable | 
[**patchAdminUsersByUserIdEnable**](AdminApi.md#patchadminusersbyuseridenable) | **PATCH** /api/v1/admin/users/{user_id}/enable | 


# **deleteAdminUsersByUserIdDevicesByDeviceId**
> deleteAdminUsersByUserIdDevicesByDeviceId(userId, deviceId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();
final String userId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String deviceId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    api.deleteAdminUsersByUserIdDevicesByDeviceId(userId, deviceId);
} on DioException catch (e) {
    print('Exception when calling AdminApi->deleteAdminUsersByUserIdDevicesByDeviceId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **deviceId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminAuditLogs**
> GetAdminAuditLogs200Response getAdminAuditLogs(limit, cursor, action)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();
final int limit = 56; // int | 
final String cursor = cursor_example; // String | 
final String action = action_example; // String | 

try {
    final response = api.getAdminAuditLogs(limit, cursor, action);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->getAdminAuditLogs: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **action** | **String**|  | [optional] 

### Return type

[**GetAdminAuditLogs200Response**](GetAdminAuditLogs200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminStatus**
> GetAdminStatus200Response getAdminStatus()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();

try {
    final response = api.getAdminStatus();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->getAdminStatus: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetAdminStatus200Response**](GetAdminStatus200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAdminUsers**
> GetAdminUsers200Response getAdminUsers(limit, cursor, search)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();
final int limit = 56; // int | 
final String cursor = cursor_example; // String | 
final String search = search_example; // String | 

try {
    final response = api.getAdminUsers(limit, cursor, search);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->getAdminUsers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **int**|  | [optional] 
 **cursor** | **String**|  | [optional] 
 **search** | **String**|  | [optional] 

### Return type

[**GetAdminUsers200Response**](GetAdminUsers200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchAdminUsersByUserIdDisable**
> PatchAdminUsersByUserIdDisable200Response patchAdminUsersByUserIdDisable(userId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();
final String userId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.patchAdminUsersByUserIdDisable(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->patchAdminUsersByUserIdDisable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**PatchAdminUsersByUserIdDisable200Response**](PatchAdminUsersByUserIdDisable200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **patchAdminUsersByUserIdEnable**
> PatchAdminUsersByUserIdDisable200Response patchAdminUsersByUserIdEnable(userId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getAdminApi();
final String userId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.patchAdminUsersByUserIdEnable(userId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AdminApi->patchAdminUsersByUserIdEnable: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 

### Return type

[**PatchAdminUsersByUserIdDisable200Response**](PatchAdminUsersByUserIdDisable200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

