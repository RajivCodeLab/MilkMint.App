import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../auth/auth_service.dart';

/// API client for making HTTP requests
class ApiClient {
  ApiClient(this._dio, this._authService) {
    _setupInterceptors();
  }

  final Dio _dio;
  final AuthService _authService;

  /// Setup Dio interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Firebase ID token to headers
          final token = await _authService.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add default headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          debugPrint('REQUEST[${options.method}] => ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );

          // Handle token expiration
          if (error.response?.statusCode == 401) {
            try {
              // Refresh token
              final newToken = await _authService.getIdToken(forceRefresh: true);
              if (newToken != null) {
                // Retry request with new token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';

                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              }
            } catch (e) {
              debugPrint('Token refresh failed: $e');
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connection timeout. Please check your internet connection.',
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] as String? ??
            'Something went wrong';

        switch (statusCode) {
          case 400:
            return ApiException(
              message,
              type: ApiExceptionType.badRequest,
              statusCode: statusCode,
            );
          case 401:
            return ApiException(
              'Unauthorized. Please login again.',
              type: ApiExceptionType.unauthorized,
              statusCode: statusCode,
            );
          case 403:
            return ApiException(
              'Access forbidden',
              type: ApiExceptionType.forbidden,
              statusCode: statusCode,
            );
          case 404:
            return ApiException(
              'Resource not found',
              type: ApiExceptionType.notFound,
              statusCode: statusCode,
            );
          case 500:
          case 502:
          case 503:
            return ApiException(
              'Server error. Please try again later.',
              type: ApiExceptionType.serverError,
              statusCode: statusCode,
            );
          default:
            return ApiException(
              message,
              type: ApiExceptionType.unknown,
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return ApiException(
          'Request cancelled',
          type: ApiExceptionType.cancel,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection',
          type: ApiExceptionType.noInternet,
        );

      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        return ApiException(
          'An unexpected error occurred',
          type: ApiExceptionType.unknown,
        );
    }
  }
}

/// API Exception types
enum ApiExceptionType {
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  cancel,
  noInternet,
  unknown,
}

/// API Exception
class ApiException implements Exception {
  ApiException(
    this.message, {
    required this.type,
    this.statusCode,
  });

  final String message;
  final ApiExceptionType type;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      sendTimeout: AppConstants.apiTimeout,
    ),
  );
});

/// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  final authService = ref.watch(authServiceProvider);
  return ApiClient(dio, authService);
});
