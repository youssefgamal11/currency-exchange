import 'package:dio/dio.dart';
import 'failure.dart';

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      failure = _handleError(error);
    } else {
      failure = ResponseType.defaultError.getFailure();
    }
  }
}

Failure _handleBadResponse(DioException error) {
  try {
    if (error.response != null) {
      final data = error.response?.data as Failure;
      String message = data.message;
      int code = error.response?.statusCode ?? 0;
      return Failure(code, message);
    }

    return ResponseType.defaultError.getFailure();
  } catch (e) {
    return ResponseType.defaultError.getFailure();
  }
}

Failure _handleUnknownError(DioException error) {
  if (error.error.toString().contains('FormatException')) {
    return ResponseType.defaultError.getFailure();
  }
  return ResponseType.noInternetConnection.getFailure();
}

Failure _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return ResponseType.connectTimeout.getFailure();
    case DioExceptionType.connectionError:
      return ResponseType.noInternetConnection.getFailure();
    case DioExceptionType.sendTimeout:
      return ResponseType.sendTimeout.getFailure();
    case DioExceptionType.receiveTimeout:
      return ResponseType.receiveTimeout.getFailure();
    case DioExceptionType.badResponse:
      return _handleBadResponse(error);
    case DioExceptionType.unknown:
      return _handleUnknownError(error);
    case DioExceptionType.cancel:
      return ResponseType.cancel.getFailure();
    default:
      return ResponseType.defaultError.getFailure();
  }
}

extension DataSourceExtension on ResponseType {
  Failure getFailure() {
    switch (this) {
      case ResponseType.noContent:
        return Failure(StatusCode.noContent, "No data was returned by the server");
      case ResponseType.badRequest:
        return Failure(StatusCode.badRequest, "Invalid request, please check your input");
      case ResponseType.forbidden:
        return Failure(StatusCode.forbidden, "You don't have permission to access this resource");
      case ResponseType.unauthorised:
        return Failure(StatusCode.unAuthorised, "Session expired, please log in again");
      case ResponseType.notFound:
        return Failure(StatusCode.notFound, "The requested resource was not found");
      case ResponseType.internalServerError:
        return Failure(StatusCode.internalServerError, "Something went wrong on our end, please try again later");
      case ResponseType.serviceUnavailable:
      case ResponseType.serviceUnavailable2:
        return Failure(StatusCode.serviceUnavailable, "Service is currently unavailable, please try again later");
      case ResponseType.connectTimeout:
        return Failure(StatusCode.connectTimeout, "Connection timed out, please check your internet connection");
      case ResponseType.cancel:
        return Failure(StatusCode.cancel, "Request was cancelled");
      case ResponseType.receiveTimeout:
        return Failure(StatusCode.receiveTimeout, "Server took too long to respond, please try again");
      case ResponseType.sendTimeout:
        return Failure(StatusCode.sendTimeout, "Request took too long to send, please try again");
      case ResponseType.cacheError:
        return Failure(StatusCode.cacheError, "Failed to load cached data");
      case ResponseType.noInternetConnection:
        return Failure(StatusCode.noInternetConnection, "No internet connection, please check your network");
      case ResponseType.defaultError:
        return Failure(StatusCode.defaultError, "An unexpected error occurred, please try again");
    }
  }
}

enum ResponseType {
  noContent,
  badRequest,
  forbidden,
  unauthorised,
  notFound,
  internalServerError,
  serviceUnavailable,
  serviceUnavailable2,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  defaultError,
}

class StatusCode {
  static const int success = 200; // success with data
  static const int noContent = 201; // success with no data (no content)
  static const int badRequest = 400; // failure, API rejected request
  static const int unAuthorised = 401; // failure, user is not authorised
  static const int forbidden = 403; //  failure, API rejected request
  static const int notFound = 404; // failure, not found
  static const int internalServerError = 500; // failure, crash in server side
  static const int serviceUnavailable = 503; // failure, service unavailable
  static const int serviceUnavailable2 = 504; // failure, service unavailable

  // local status code
  static const int connectTimeout = -1;
  static const int cancel = -2;
  static const int receiveTimeout = -3;
  static const int sendTimeout = -4;
  static const int cacheError = -5;
  static const int noInternetConnection = -6;
  static const int defaultError = -7;
}
