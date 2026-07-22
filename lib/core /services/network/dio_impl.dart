import 'dart:developer';
import 'package:axis/core%20/services/error/failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'interceptors.dart';
import 'network_helper.dart';

@LazySingleton(as: NetworkHelper)
class DioImpl implements NetworkHelper {
  late Dio _dio;
  static const _kConnectTimeout = 120;

  DioImpl() {
    _dio = Dio()
      ..interceptors.addAll([
        LanguageAndContentTypeInterceptor(),
        if (kDebugMode)
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            error: true,
          ),
      ]);

    _dio.options.connectTimeout = const Duration(seconds: _kConnectTimeout);
  }

  Dio get dio => _dio; // Expose Dio instance if needed

  void _onSendProgress(int count, int total) {
    if (kDebugMode) {
      if (count == total) {
        log('Request progress Done 100%');
      } else {
        log('Request progress : ${(count / total).toStringAsFixed(2)} %');
      }
    }
  }

  @override
  Future<dynamic> get({
    required String path,
    bool isFullPath = false,
    Map<String, dynamic>? body,
    int apiVersion = 1,
    CancelToken? cancelToken,
    FormData? formData,
    ResponseType? responseType,
    Map<String, dynamic>? queryParams,
    Function(int? count, int? total)? onReceiveProgress,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParams,
      data: formData ?? body,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
      options: Options(validateStatus: (_) => true, responseType: responseType),
    );
    return _validateAndReturnResponse(response, path);
  }

  @override
  Future<dynamic> post({
    required String path,
    bool isFullPath = false,
    Map<String, dynamic>? body,
    FormData? formData,
    int apiVersion = 1,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Map<String, dynamic>? queryParams,
    Function(int? count, int? total)? onSendProgress,
    Function(int? count, int? total)? onReceiveProgress,
  }) async {
  
    final response = await _dio.post(
      path,
      data: formData ?? body,
      queryParameters: queryParams,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress ?? _onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: Options(validateStatus: (_) => true, responseType: responseType),
    );
    return _validateAndReturnResponse(response, path);
  }

  dynamic _validateAndReturnResponse(Response response, String route) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      // Handle bytes responses (like images) differently from JSON responses
      String errorMessage;
      if (response.data is List<int>) {
        // For bytes responses, just use the status code
        errorMessage = 'Request failed with status: ${response.statusCode}';
      } else if (response.data is Map<String, dynamic>) {
        // For JSON responses, try to get user_message
        errorMessage =
            response.data['user_message'] ?? response.statusCode.toString();
      } else {
        // For other response types, use status code
        errorMessage = response.statusCode.toString();
      }

      throw DioException(
        requestOptions: RequestOptions(path: route),
        type: DioExceptionType.badResponse,
        response: Response<Failure>(
          data: Failure(-1, errorMessage),
          statusCode: response.statusCode,
          requestOptions: RequestOptions(path: route),
        ),
      );
    }
  }
}
