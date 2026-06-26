import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  });
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Future<UserModel> _authenticate({
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      rethrowDioException(e);
    }
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) {
    final request = LoginRequestModel(
      username: username,
      password: password,
    );
    return _authenticate(
      endpoint: ApiConstants.loginEndpoint,
      data: request.toJson(),
    );
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) {
    final request = RegisterRequestModel(
      username: username,
      email: email,
      password: password,
    );
    return _authenticate(
      endpoint: ApiConstants.registerEndpoint,
      data: request.toJson(),
    );
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.getMeEndpoint);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Unauthorized');
      }
      throw mapDioToServerException(e);
    }
  }
}
