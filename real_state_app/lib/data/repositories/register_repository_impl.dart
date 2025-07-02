// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';
import 'package:real_state_app/domain/entities/register_entity.dart';
import 'package:real_state_app/domain/repositories/auth_repository.dart';
import 'package:real_state_app/data/models/register_request.dart';
import 'package:real_state_app/data/models/register_response.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterRepositoryImpl implements RegisterRepository {
  @override
  Future<RegisterResult> register(RegisterEntity entity) async {
    try {
      final request = RegisterRequest(
        email: entity.email,
        password: entity.password,
        firstName: entity.firstName,
        lastName: entity.lastName,
        phone: entity.phone,
        role: entity.role,
        company: entity.company,
        licenseNumber: entity.licenseNumber,
      );
      final response = await http.post(
        Uri.parse(dotenv.env['HTTP_REGISTRATION_URL']!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final registerResponse = RegisterResponse.fromJson(data);
        await LocalStorage.saveToken(registerResponse.accessToken);
        return RegisterResult(
          isSuccess: true,
          token: registerResponse.accessToken,
          user: registerResponse.user,
        );
      } else {
        return RegisterResult(isSuccess: false, error: 'Registration failed');
      }
    } catch (e) {
      return RegisterResult(isSuccess: false, error: e.toString());
    }
  }
}
