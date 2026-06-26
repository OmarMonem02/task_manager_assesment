import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'username': username, 'password': password, 'expiresInMins': 60},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Invalid credentials',
        );
      }
      throw ServerException(e.message ?? 'Server error');
    }
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
      throw ServerException(e.message ?? 'Server error');
    }
  }
}