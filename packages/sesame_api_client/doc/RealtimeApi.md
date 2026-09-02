# sesame_api_client.api.RealtimeApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**postWsTicket**](RealtimeApi.md#postwsticket) | **POST** /api/v1/ws/ticket | 


# **postWsTicket**
> PostWsTicket200Response postWsTicket()



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getRealtimeApi();

try {
    final response = api.postWsTicket();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RealtimeApi->postWsTicket: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PostWsTicket200Response**](PostWsTicket200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

