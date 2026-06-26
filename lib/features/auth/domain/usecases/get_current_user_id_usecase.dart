import '../repositories/auth_repository.dart';

class GetCurrentUserIdUseCase {
  GetCurrentUserIdUseCase(this._repository);

  final AuthRepository _repository;

  Future<int?> call() => _repository.getCurrentUserId();
}
