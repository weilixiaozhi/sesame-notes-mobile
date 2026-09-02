# sesame_api_client.api.SharingApi

## Load the API package
```dart
import 'package:sesame_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteLedgersByLedgerIdInvitesByInviteId**](SharingApi.md#deleteledgersbyledgeridinvitesbyinviteid) | **DELETE** /api/v1/ledgers/{ledger_id}/invites/{invite_id} | 
[**deleteLedgersByLedgerIdMembersByMemberId**](SharingApi.md#deleteledgersbyledgeridmembersbymemberid) | **DELETE** /api/v1/ledgers/{ledger_id}/members/{member_id} | 
[**getInvitesByCode**](SharingApi.md#getinvitesbycode) | **GET** /api/v1/invites/{code} | 
[**getLedgersByLedgerIdInvites**](SharingApi.md#getledgersbyledgeridinvites) | **GET** /api/v1/ledgers/{ledger_id}/invites | 
[**getLedgersByLedgerIdMemberStats**](SharingApi.md#getledgersbyledgeridmemberstats) | **GET** /api/v1/ledgers/{ledger_id}/member-stats | 
[**getLedgersByLedgerIdMembers**](SharingApi.md#getledgersbyledgeridmembers) | **GET** /api/v1/ledgers/{ledger_id}/members | 
[**getLedgersByLedgerIdSharedResources**](SharingApi.md#getledgersbyledgeridsharedresources) | **GET** /api/v1/ledgers/{ledger_id}/shared-resources | 
[**postInvitesByCodeAccept**](SharingApi.md#postinvitesbycodeaccept) | **POST** /api/v1/invites/{code}/accept | 
[**postLedgersByLedgerIdInvites**](SharingApi.md#postledgersbyledgeridinvites) | **POST** /api/v1/ledgers/{ledger_id}/invites | 
[**postLedgersByLedgerIdLeave**](SharingApi.md#postledgersbyledgeridleave) | **POST** /api/v1/ledgers/{ledger_id}/leave | 
[**postLedgersByLedgerIdMembersByMemberIdClaim**](SharingApi.md#postledgersbyledgeridmembersbymemberidclaim) | **POST** /api/v1/ledgers/{ledger_id}/members/{member_id}/claim | 


# **deleteLedgersByLedgerIdInvitesByInviteId**
> deleteLedgersByLedgerIdInvitesByInviteId(ledgerId, inviteId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String inviteId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    api.deleteLedgersByLedgerIdInvitesByInviteId(ledgerId, inviteId);
} on DioException catch (e) {
    print('Exception when calling SharingApi->deleteLedgersByLedgerIdInvitesByInviteId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **inviteId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteLedgersByLedgerIdMembersByMemberId**
> deleteLedgersByLedgerIdMembersByMemberId(ledgerId, memberId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String memberId = 056cf10d-2d59-599c-9d97-6749e866aa52; // String | 

try {
    api.deleteLedgersByLedgerIdMembersByMemberId(ledgerId, memberId);
} on DioException catch (e) {
    print('Exception when calling SharingApi->deleteLedgersByLedgerIdMembersByMemberId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **memberId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getInvitesByCode**
> GetInvitesByCode200Response getInvitesByCode(code)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String code = code_example; // String | 

try {
    final response = api.getInvitesByCode(code);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->getInvitesByCode: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

[**GetInvitesByCode200Response**](GetInvitesByCode200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdInvites**
> BuiltList<GetLedgersByLedgerIdInvites200ResponseInner> getLedgersByLedgerIdInvites(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getLedgersByLedgerIdInvites(ledgerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->getLedgersByLedgerIdInvites: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

[**BuiltList&lt;GetLedgersByLedgerIdInvites200ResponseInner&gt;**](GetLedgersByLedgerIdInvites200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdMemberStats**
> GetLedgersByLedgerIdMemberStats200Response getLedgersByLedgerIdMemberStats(ledgerId, scope, period, tzOffsetMinutes)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String scope = scope_example; // String | 
final String period = period_example; // String | 
final int tzOffsetMinutes = 56; // int | 

try {
    final response = api.getLedgersByLedgerIdMemberStats(ledgerId, scope, period, tzOffsetMinutes);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->getLedgersByLedgerIdMemberStats: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **scope** | **String**|  | [optional] 
 **period** | **String**|  | [optional] 
 **tzOffsetMinutes** | **int**|  | [optional] 

### Return type

[**GetLedgersByLedgerIdMemberStats200Response**](GetLedgersByLedgerIdMemberStats200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdMembers**
> BuiltList<GetLedgersByLedgerIdMembers200ResponseInner> getLedgersByLedgerIdMembers(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getLedgersByLedgerIdMembers(ledgerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->getLedgersByLedgerIdMembers: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

[**BuiltList&lt;GetLedgersByLedgerIdMembers200ResponseInner&gt;**](GetLedgersByLedgerIdMembers200ResponseInner.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLedgersByLedgerIdSharedResources**
> GetLedgersByLedgerIdSharedResources200Response getLedgersByLedgerIdSharedResources(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    final response = api.getLedgersByLedgerIdSharedResources(ledgerId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->getLedgersByLedgerIdSharedResources: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 

### Return type

[**GetLedgersByLedgerIdSharedResources200Response**](GetLedgersByLedgerIdSharedResources200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postInvitesByCodeAccept**
> PostInvitesByCodeAccept200Response postInvitesByCodeAccept(code)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String code = code_example; // String | 

try {
    final response = api.postInvitesByCodeAccept(code);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->postInvitesByCodeAccept: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**|  | 

### Return type

[**PostInvitesByCodeAccept200Response**](PostInvitesByCodeAccept200Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postLedgersByLedgerIdInvites**
> PostLedgersByLedgerIdInvites201Response postLedgersByLedgerIdInvites(ledgerId, postLedgersByLedgerIdInvitesRequest)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final PostLedgersByLedgerIdInvitesRequest postLedgersByLedgerIdInvitesRequest = ; // PostLedgersByLedgerIdInvitesRequest | 

try {
    final response = api.postLedgersByLedgerIdInvites(ledgerId, postLedgersByLedgerIdInvitesRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling SharingApi->postLedgersByLedgerIdInvites: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **postLedgersByLedgerIdInvitesRequest** | [**PostLedgersByLedgerIdInvitesRequest**](PostLedgersByLedgerIdInvitesRequest.md)|  | 

### Return type

[**PostLedgersByLedgerIdInvites201Response**](PostLedgersByLedgerIdInvites201Response.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postLedgersByLedgerIdLeave**
> postLedgersByLedgerIdLeave(ledgerId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 

try {
    api.postLedgersByLedgerIdLeave(ledgerId);
} on DioException catch (e) {
    print('Exception when calling SharingApi->postLedgersByLedgerIdLeave: $e\n');
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

# **postLedgersByLedgerIdMembersByMemberIdClaim**
> postLedgersByLedgerIdMembersByMemberIdClaim(ledgerId, memberId)



### Example
```dart
import 'package:sesame_api_client/api.dart';

final api = SesameApiClient().getSharingApi();
final String ledgerId = 018f7f95-4b8a-4f5e-8d0c-2ebf4682c761; // String | 
final String memberId = 056cf10d-2d59-599c-9d97-6749e866aa52; // String | 

try {
    api.postLedgersByLedgerIdMembersByMemberIdClaim(ledgerId, memberId);
} on DioException catch (e) {
    print('Exception when calling SharingApi->postLedgersByLedgerIdMembersByMemberIdClaim: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **ledgerId** | **String**|  | 
 **memberId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

