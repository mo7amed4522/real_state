import '../entities/register_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase(this.repository);

  Future<RegisterResult> call(RegisterEntity entity) {
    return repository.register(entity);
  }
}
