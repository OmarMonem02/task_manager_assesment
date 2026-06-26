import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../network/api_constants.dart';
import '../network/token_provider.dart';

class DioFactory {
  DioFactory(this._tokenProvider);

  final TokenProvider _tokenProvider;

  Dio createAuthDio() {
    return _createDio(
      baseUrl: ApiConstants.authBaseUrl,
      validateStatus: null,
    );
  }

  Dio createProjectsDio() {
    return _createDio(
      baseUrl: ApiConstants.projectsBaseUrl,
      validateStatus: (status) => status != null && status < 500,
    );
  }

  Dio _createDio({
    required String baseUrl,
    bool Function(int?)? validateStatus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
        validateStatus: validateStatus,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}
