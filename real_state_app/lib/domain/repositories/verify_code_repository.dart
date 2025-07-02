import '../entities/verified_email_entity.dart';

abstract class VerifyCodeRepository {
  Future<VerifiyCodeResult> verifyCode(VerifiedEmailEntity entity);
}

class VerifiyCodeResult {
  final bool isSuccess;
  final dynamic verify;
  final String? error;
  VerifiyCodeResult({required this.isSuccess, this.verify, this.error});
}
