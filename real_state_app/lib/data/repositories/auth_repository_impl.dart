// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:real_state_app/data/models/get_own_data_request.dart';
import 'package:real_state_app/data/models/login_request.dart';
import 'package:real_state_app/data/models/login_response.dart';
import 'package:real_state_app/domain/entities/user_entity.dart';
import 'package:real_state_app/domain/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthResult> login(UserEntity entity) async {
    try {
      final request = LoginRequest(
        email: entity.email,
        password: entity.password,
      );
      final response = await http.post(
        Uri.parse(dotenv.env['HTTP_LOGIN_URL']!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      debugPrint('response: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        debugPrint("active status: ${loginResponse.user.status.toString()}");

        await LocalStorage.saveToken(loginResponse.accessToken);
        return AuthResult(
          isSuccess: true,
          token: loginResponse.accessToken,
          user: loginResponse.user,
          status: loginResponse.user.status,
        );
      } else {
        return AuthResult(
          isSuccess: false,
          error: 'Registration failed',
          status: "pending_verification",
        );
      }
    } catch (e) {
      return AuthResult(isSuccess: false, error: e.toString(), status: "Error");
    }
  }

  Future<GetOwnDataRequest> getOwnProfile(String token) async {
    final response = await http.get(
      Uri.parse(
        dotenv.env['HTTP_GET_OWN_PROFILE'] ??
            'https://your.api.url/auth/profile',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    debugPrint('response getOwnProfile: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return GetOwnDataRequest.fromJson(data);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}
