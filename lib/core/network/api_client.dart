import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'network_info.dart';

class ApiClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  ApiClient({Dio? dio, NetworkInfo? networkInfo})
    : _dio = dio ?? Dio(),
      _networkInfo =
          networkInfo ?? NetworkInfoImpl(InternetConnectionChecker()) {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Logging interceptor for debug mode
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          if (options.path.contains('/posts')) {
            return false;
          }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    // Check network connectivity before making request
    final isOnline = await _networkInfo.isConnected;
    if (!isOnline) {
      throw const NoInternetException(
        'No internet connection. Please check your network and try again.',
      );
    }

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  ServerException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          'Connection timed out. Please try again.',
          statusCode: 408,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const ServerException(
            'Pokémon or resource not found.',
            statusCode: 404,
          );
        } else if (statusCode == 429) {
          return const ServerException(
            'Too many requests. Please slow down.',
            statusCode: 429,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            'PokeAPI server error ($statusCode). Please try again later.',
            statusCode: statusCode,
          );
        }
        return ServerException(
          'Failed with status code: $statusCode',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return const ServerException(
          'Unable to reach server. Please check your connection.',
          statusCode: 503,
        );
      case DioExceptionType.cancel:
        return const ServerException('Request was cancelled.');
      default:
        return ServerException(e.message ?? 'Unknown network error occurred.');
    }
  }
}
