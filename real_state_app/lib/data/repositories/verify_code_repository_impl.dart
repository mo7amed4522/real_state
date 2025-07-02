// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:real_state_app/data/models/verify_code_request.dart';
import 'package:real_state_app/data/models/verify_code_response.dart';
import 'dart:convert';

import '../../domain/entities/verified_email_entity.dart';
import '../../domain/repositories/verify_code_repository.dart';

class VerifyCodeRepositoryImpl implements VerifyCodeRepository {
  @override
  Future<VerifiyCodeResult> verifyCode(VerifiedEmailEntity entity) async {
    try {
      final request = VerifyCodeRequest(token: entity.token);
      final response = await http.post(
        Uri.parse(dotenv.env['HTTP_VERIFY_CODE_URL']!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final registerResponse = VerifyCodeResponse.fromJson(data);
        return VerifiyCodeResult(
          isSuccess: true,
          verify: registerResponse.message,
        );
      } else {
        return VerifiyCodeResult(
          isSuccess: false,
          error: 'Verifying email failed',
        );
      }
    } catch (e) {
      return VerifiyCodeResult(isSuccess: false, error: e.toString());
    }
  }
}
