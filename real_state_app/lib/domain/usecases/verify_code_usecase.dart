import '../entities/verified_email_entity.dart';
import '../repositories/verify_code_repository.dart';

class VerifyCodeUseCase {
  final VerifyCodeRepository repository;

  VerifyCodeUseCase(this.repository);

  Future<VerifiyCodeResult> call(VerifiedEmailEntity entity) async {
    return repository.verifyCode(entity);
  }
}
