import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

ServerException mapDioToServerException(
  DioException e, {
  String fallback = 'Server error',
}) {
  return ServerException(e.message ?? fallback);
}

UnauthorizedException mapDioToUnauthorizedException(
  DioException e, {
  String fallback = 'Invalid credentials',
}) {
  final message = e.response?.data is Map
      ? (e.response?.data['message'] as String?) ?? fallback
      : fallback;
  return UnauthorizedException(message);
}

Never rethrowDioException(
  DioException e, {
  int unauthorizedStatus = 401,
  int badRequestStatus = 400,
  String unauthorizedFallback = 'Invalid credentials',
  String serverFallback = 'Server error',
}) {
  final status = e.response?.statusCode;
  if (status == badRequestStatus || status == unauthorizedStatus) {
    throw mapDioToUnauthorizedException(e, fallback: unauthorizedFallback);
  }
  throw mapDioToServerException(e, fallback: serverFallback);
}

bool isNotFound(DioException e) => e.response?.statusCode == 404;
