//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'dart:typed_data';
import 'package:sesame_api_client/src/api_util.dart';
import 'package:sesame_api_client/src/model/error.dart';
import 'package:sesame_api_client/src/model/get_fitness_catalog200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_calendar200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_preferences200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_statistics200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_import200_response.dart';
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_import_request.dart';
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command200_response.dart';
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request.dart';

class FitnessApi {
  final Dio _dio;

  final Serializers _serializers;

  const FitnessApi(this._dio, this._serializers);

  /// getFitnessCatalog
  ///
  ///
  /// Parameters:
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessCatalog200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessCatalog200Response>> getFitnessCatalog({
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness/catalog';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessCatalog200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(GetFitnessCatalog200Response),
            ) as GetFitnessCatalog200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessCatalog200Response>(
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

  /// getFitnessLibrary
  ///
  ///
  /// Parameters:
  /// * [ifNoneMatch]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessLibrary200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessLibrary200Response>> getFitnessLibrary({
    String? ifNoneMatch,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness/library';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        if (ifNoneMatch != null) r'if-none-match': ifNoneMatch,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessLibrary200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(GetFitnessLibrary200Response),
            ) as GetFitnessLibrary200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessLibrary200Response>(
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

  /// getFitnessMediaByMediaId
  ///
  ///
  /// Parameters:
  /// * [mediaId]
  /// * [preview]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Uint8List] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Uint8List>> getFitnessMediaByMediaId({
    required String mediaId,
    String? preview,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness/media/{media_id}'.replaceAll(
        '{' r'media_id' '}',
        encodeQueryParameter(_serializers, mediaId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'GET',
      responseType: ResponseType.bytes,
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (preview != null)
        r'preview':
            encodeQueryParameter(_serializers, preview, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Uint8List? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null ? null : rawResponse as Uint8List;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Uint8List>(
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

  /// getFitnessSpacesByFitnessSpaceIdCalendar
  ///
  ///
  /// Parameters:
  /// * [startDate]
  /// * [endDate]
  /// * [fitnessSpaceId]
  /// * [timeZone]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdCalendar200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdCalendar200Response>>
      getFitnessSpacesByFitnessSpaceIdCalendar({
    required String startDate,
    required String endDate,
    required String fitnessSpaceId,
    String? timeZone,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/calendar'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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
      r'start_date':
          encodeQueryParameter(_serializers, startDate, const FullType(String)),
      r'end_date':
          encodeQueryParameter(_serializers, endDate, const FullType(String)),
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

    GetFitnessSpacesByFitnessSpaceIdCalendar200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdCalendar200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdCalendar200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdExport
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdExport200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdExport200Response>>
      getFitnessSpacesByFitnessSpaceIdExport({
    required String fitnessSpaceId,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/export'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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

    GetFitnessSpacesByFitnessSpaceIdExport200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdExport200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdExport200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdExport200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdPlans
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [limit]
  /// * [cursor]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdPlans200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdPlans200Response>>
      getFitnessSpacesByFitnessSpaceIdPlans({
    required String fitnessSpaceId,
    int? limit,
    String? cursor,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/plans'.replaceAll(
        '{' r'fitness_space_id' '}',
        encodeQueryParameter(
                _serializers, fitnessSpaceId, const FullType(String))
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
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessSpacesByFitnessSpaceIdPlans200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdPlans200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdPlans200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdPreferences
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [limit]
  /// * [cursor]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdPreferences200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdPreferences200Response>>
      getFitnessSpacesByFitnessSpaceIdPreferences({
    required String fitnessSpaceId,
    int? limit,
    String? cursor,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/preferences'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessSpacesByFitnessSpaceIdPreferences200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdPreferences200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdPreferences200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdStatistics
  ///
  ///
  /// Parameters:
  /// * [startDate]
  /// * [endDate]
  /// * [fitnessSpaceId]
  /// * [timeZone]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdStatistics200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdStatistics200Response>>
      getFitnessSpacesByFitnessSpaceIdStatistics({
    required String startDate,
    required String endDate,
    required String fitnessSpaceId,
    String? timeZone,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/statistics'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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
      r'start_date':
          encodeQueryParameter(_serializers, startDate, const FullType(String)),
      r'end_date':
          encodeQueryParameter(_serializers, endDate, const FullType(String)),
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

    GetFitnessSpacesByFitnessSpaceIdStatistics200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdStatistics200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdStatistics200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdTemplates
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [limit]
  /// * [cursor]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdTemplates200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdTemplates200Response>>
      getFitnessSpacesByFitnessSpaceIdTemplates({
    required String fitnessSpaceId,
    int? limit,
    String? cursor,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/templates'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessSpacesByFitnessSpaceIdTemplates200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdTemplates200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdTemplates200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdWorkouts
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [limit]
  /// * [cursor]
  /// * [syncId]
  /// * [exerciseId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdWorkouts200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GetFitnessSpacesByFitnessSpaceIdWorkouts200Response>>
      getFitnessSpacesByFitnessSpaceIdWorkouts({
    required String fitnessSpaceId,
    int? limit,
    String? cursor,
    String? syncId,
    String? exerciseId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/workouts'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
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
      if (exerciseId != null)
        r'exercise_id': encodeQueryParameter(
            _serializers, exerciseId, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    GetFitnessSpacesByFitnessSpaceIdWorkouts200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200Response),
            ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GetFitnessSpacesByFitnessSpaceIdWorkouts200Response>(
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

  /// getFitnessSpacesByFitnessSpaceIdWorkoutsByWorkoutId
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [workoutId]
  /// * [syncId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner] as data
  /// Throws [DioException] if API call or serialization fails
  Future<
          Response<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>>
      getFitnessSpacesByFitnessSpaceIdWorkoutsByWorkoutId({
    required String fitnessSpaceId,
    required String workoutId,
    String? syncId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path =
        r'/api/v1/fitness-spaces/{fitness_space_id}/workouts/{workout_id}'
            .replaceAll(
                '{' r'fitness_space_id' '}',
                encodeQueryParameter(
                        _serializers, fitnessSpaceId, const FullType(String))
                    .toString())
            .replaceAll(
                '{' r'workout_id' '}',
                encodeQueryParameter(
                        _serializers, workoutId, const FullType(String))
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

    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner?
        _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner),
            ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>(
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

  /// postFitnessSpacesByFitnessSpaceIdImport
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [postFitnessSpacesByFitnessSpaceIdImportRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PostFitnessSpacesByFitnessSpaceIdImport200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PostFitnessSpacesByFitnessSpaceIdImport200Response>>
      postFitnessSpacesByFitnessSpaceIdImport({
    required String fitnessSpaceId,
    required PostFitnessSpacesByFitnessSpaceIdImportRequest
        postFitnessSpacesByFitnessSpaceIdImportRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/fitness-spaces/{fitness_space_id}/import'
        .replaceAll(
            '{' r'fitness_space_id' '}',
            encodeQueryParameter(
                    _serializers, fitnessSpaceId, const FullType(String))
                .toString());
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(PostFitnessSpacesByFitnessSpaceIdImportRequest);
      _bodyData = _serializers.serialize(
          postFitnessSpacesByFitnessSpaceIdImportRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PostFitnessSpacesByFitnessSpaceIdImport200Response? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  PostFitnessSpacesByFitnessSpaceIdImport200Response),
            ) as PostFitnessSpacesByFitnessSpaceIdImport200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PostFitnessSpacesByFitnessSpaceIdImport200Response>(
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

  /// postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand
  ///
  ///
  /// Parameters:
  /// * [fitnessSpaceId]
  /// * [planId]
  /// * [postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response] as data
  /// Throws [DioException] if API call or serialization fails
  Future<
          Response<
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response>>
      postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand({
    required String fitnessSpaceId,
    required String planId,
    required PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
        postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path =
        r'/api/v1/fitness-spaces/{fitness_space_id}/plans/{plan_id}/command'
            .replaceAll(
                '{' r'fitness_space_id' '}',
                encodeQueryParameter(
                        _serializers, fitnessSpaceId, const FullType(String))
                    .toString())
            .replaceAll(
                '{' r'plan_id' '}',
                encodeQueryParameter(
                        _serializers, planId, const FullType(String))
                    .toString());
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest);
      _bodyData = _serializers.serialize(
          postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest,
          specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response?
        _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response),
            ) as PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response>(
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
