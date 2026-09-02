# sesame_api_client.api.DevicesApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteDevicesByDeviceId**](DevicesApi.md#deletedevicesbydeviceid) | **DELETE** /api/v1/devices/{device_id} | 
[**getDevices**](DevicesApi.md#getdevices) | **GET** /api/v1/devices | 


# **deleteDevicesByDeviceId**
> deleteDevicesByDeviceId(deviceId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getDevicesApi();
final String deviceId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    api.deleteDevicesByDeviceId(deviceId);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->deleteDevicesByDeviceId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deviceId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDevices**
> BuiltList<GetDevices200ResponseInner> getDevices()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getDevicesApi();

try {
    final response = api.getDevices();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DevicesApi->getDevices: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;GetDevices200ResponseInner&gt;**](GetDevices200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

