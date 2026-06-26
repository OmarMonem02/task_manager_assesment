import '../../../auth/domain/entities/user_entity.dart';

abstract class UserReader {
  Future<UserEntity> getMe();
}
