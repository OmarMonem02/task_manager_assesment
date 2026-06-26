import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_reader.dart';

class AuthUserReader implements UserReader {
  AuthUserReader(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<UserEntity> getMe() => _authRepository.getMe();
}
