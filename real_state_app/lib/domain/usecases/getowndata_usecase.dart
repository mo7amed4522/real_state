import 'package:real_state_app/domain/entities/get_own_entity.dart';
import 'package:real_state_app/domain/repositories/auth_repository.dart';

class GetOwnDataUseCase {
  final GetOwnUserRepository repository;
  GetOwnDataUseCase(this.repository);

  Future<GetOwnUserResult> call(GetOwnEntity enitiy) {
    return repository.getUserData(enitiy);
  }
}
