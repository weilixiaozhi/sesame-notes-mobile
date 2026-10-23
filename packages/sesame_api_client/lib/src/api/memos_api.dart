//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:sesame_api_client/src/api_util.dart';
import 'package:sesame_api_client/src/model/error.dart';
import 'package:sesame_api_client/src/model/get_memo_books_by_memo_book_id_calendar_counts200_response.dart';
import 'package:sesame_api_client/src/model/get_memo_books_by_memo_book_id_entries200_response.dart';

class MemosApi {
  final Dio _dio;

  final Serializers _serializers;

  const MemosApi(this._dio, this._serializers);

  /// getMemoBooksByMemoBookIdCalendarCounts
  ///
  ///
  /// Parameters:
  /// * [memoBookId]
  /// * [startAt]
  /// * [endAt]
  /// * [timeZone]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetMemoBooksByMemoBookIdCalendarCounts200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetMemoBooksByMemoBookIdCalendarCounts200Response>>
      getMemoBooksByMemoBookIdCalendarCounts({
    required String memoBookId,
    DateTime? startAt,
    DateTime? endAt,
    String? timeZone,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/memo-books/{memo_book_id}/calendar-counts'
        .replaceAll(
            '{' r'memo_book_id' '}',
            encodeQueryParameter(
                    _serializers, memoBookId, const FullType(String))
                .toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (startAt != null)
        r'start_at': encodeQueryParameter(
            _serializers, startAt, const FullType(DateTime)),
      if (endAt != null)
        r'end_at':
            encodeQueryParameter(_serializers, endAt, const FullType(DateTime)),
      if (timeZone != null)
        r'time_zone': encodeQueryParameter(
            _serializers, timeZone, const FullType(String)),
      if (syncId != null)
        r'sync_id':
            encodeQueryParameter(_serializers, syncId, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetMemoBooksByMemoBookIdCalendarCounts200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetMemoBooksByMemoBookIdCalendarCounts200Response),
            ) as GetMemoBooksByMemoBookIdCalendarCounts200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetMemoBooksByMemoBookIdCalendarCounts200Response>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// getMemoBooksByMemoBookIdEntries
  ///
  ///
  /// Parameters:
  /// * [memoBookId]
  /// * [limit]
  /// * [cursor]
  /// * [syncId]
  /// * [startAt]
  /// * [endAt]
  /// * [timeZone]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetMemoBooksByMemoBookIdEntries200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetMemoBooksByMemoBookIdEntries200Response>>
      getMemoBooksByMemoBookIdEntries({
    required String memoBookId,
    int? limit,
    String? cursor,
    String? syncId,
    DateTime? startAt,
    DateTime? endAt,
    String? timeZone,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/memo-books/{memo_book_id}/entries'.replaceAll(
        '{' r'memo_book_id' '}',
        encodeQueryParameter(_serializers, memoBookId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (syncId != null)
        r'sync_id':
            encodeQueryParameter(_serializers, syncId, const FullType(String)),
      if (startAt != null)
        r'start_at': encodeQueryParameter(
            _serializers, startAt, const FullType(DateTime)),
      if (endAt != null)
        r'end_at':
            encodeQueryParameter(_serializers, endAt, const FullType(DateTime)),
      if (timeZone != null)
        r'time_zone': encodeQueryParameter(
            _serializers, timeZone, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetMemoBooksByMemoBookIdEntries200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType:
                  const FullType(GetMemoBooksByMemoBookIdEntries200Response),
            ) as GetMemoBooksByMemoBookIdEntries200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetMemoBooksByMemoBookIdEntries200Response>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
