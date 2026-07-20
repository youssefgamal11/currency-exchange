import 'package:dio/dio.dart';

abstract class NetworkHelper {
  Future<dynamic> get({
    required String path,
    bool isFullPath,
    int apiVersion = 1,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    FormData? formData,
    Function(int? count, int? total)? onReceiveProgress,
  });

  Future<dynamic> post({
    required String path,
    bool isFullPath,
    Map<String, dynamic>? body,
    FormData? formData,
    int apiVersion = 1,
    CancelToken? cancelToken,
    ResponseType? responseType,
    Map<String, dynamic>? queryParams,
    Function(int? count, int? total)? onSendProgress,
    Function(int? count, int? total)? onReceiveProgress,
  });


}
