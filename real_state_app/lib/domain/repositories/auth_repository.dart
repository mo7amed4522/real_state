import 'package:real_state_app/domain/entities/get_own_entity.dart';
import 'package:real_state_app/domain/entities/register_entity.dart';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResult> login(UserEntity entity);
}

class AuthResult {
  final bool isSuccess;
  final String? token;
  final dynamic user;
  final String status;
  final String? error;

  const AuthResult({
    required this.isSuccess,
    this.token,
    required this.status,
    this.user,
    this.error,
  });
}

abstract class RegisterRepository {
  Future<RegisterResult> register(RegisterEntity entity);
}

class RegisterResult {
  final bool isSuccess;
  final String? token;
  final dynamic user;
  final String? error;

  RegisterResult({required this.isSuccess, this.token, this.user, this.error});
}

abstract class GetOwnUserRepository {
  Future<GetOwnUserResult> getUserData(GetOwnEntity entity);
}

class GetOwnUserResult {
  final bool isSuccess;
  final dynamic user;
  final String? error;
  GetOwnUserResult({required this.isSuccess, this.user, this.error});
}
