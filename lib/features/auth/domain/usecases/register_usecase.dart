import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String username,
    required String email,
    required String password,
  }) {
    return _repository.register(username: username, email: email, password: password);
  }
}