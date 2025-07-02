import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthResult> call(UserEntity entity) {
    return repository.login(entity);
  }
}
