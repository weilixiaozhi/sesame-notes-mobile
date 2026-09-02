# sesame_api_client.api.SyncApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSyncFull**](SyncApi.md#getsyncfull) | **GET** /api/v1/sync/full | 
[**getSyncPull**](SyncApi.md#getsyncpull) | **GET** /api/v1/sync/pull | 
[**postSyncPush**](SyncApi.md#postsyncpush) | **POST** /api/v1/sync/push | 


# **getSyncFull**
> GetSyncFull200Response getSyncFull(ledgerId, syncId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSyncApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String syncId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getSyncFull(ledgerId, syncId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SyncApi->getSyncFull: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **syncId** | **String**|  | [optional] 

### Return type

[**GetSyncFull200Response**](GetSyncFull200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSyncPull**
> GetSyncPull200Response getSyncPull(since, limit)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSyncApi();
final String since = since_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.getSyncPull(since, limit);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SyncApi->getSyncPull: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**GetSyncPull200Response**](GetSyncPull200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postSyncPush**
> PostSyncPush200Response postSyncPush(postSyncPushRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSyncApi();
final PostSyncPushRequest postSyncPushRequest = ; // PostSyncPushRequest | 

try {
    final response = api.postSyncPush(postSyncPushRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SyncApi->postSyncPush: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **postSyncPushRequest** | [**PostSyncPushRequest**](PostSyncPushRequest.md)|  | 

### Return type

[**PostSyncPush200Response**](PostSyncPush200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

