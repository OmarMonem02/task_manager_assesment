import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_error_mapper.dart';

class DioProjectsClient {
  DioProjectsClient(this._dio);

  final Dio _dio;

  Future<List<T>> getList<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
    String errorMessage = 'Failed to fetch data',
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 404) return [];
      final data = response.data;
      if (data is! List) return [];
      return data
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw mapDioToServerException(e, fallback: errorMessage);
    } catch (_) {
      throw ServerException(errorMessage);
    }
  }

  Future<T> post<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic> json) fromJson,
    String errorMessage = 'Request failed',
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw mapDioToServerException(e, fallback: errorMessage);
    }
  }

  Future<T> patch<T>({
    required String endpoint,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic> json) fromJson,
    String errorMessage = 'Request failed',
  }) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw mapDioToServerException(e, fallback: errorMessage);
    }
  }

  Future<void> delete({
    required String endpoint,
    String errorMessage = 'Delete failed',
  }) async {
    try {
      final response = await _dio.delete(endpoint);
      if (response.statusCode == 404) return;
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw ServerException(errorMessage);
      }
    } on DioException catch (e) {
      if (isNotFound(e)) return;
      throw mapDioToServerException(e, fallback: errorMessage);
    }
  }
}
