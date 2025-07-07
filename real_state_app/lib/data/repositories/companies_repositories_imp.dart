import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:real_state_app/data/models/company.dart';
import 'package:real_state_app/domain/entities/comapnies.dart';
import 'package:real_state_app/domain/repositories/company_repositories.dart';
import 'package:http/http.dart' as http;

class CompaniesRepositoriesImp implements CompanyRepositories {
  @override
  Future<CompanyResult> fetchData(ComapniesEnitity entity) async {
    final response = await http.get(
      Uri.parse(
        dotenv.env['HTTP_GET_COMPANIES_URL'] ??
            'https://your.api.url/auth/profile',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final companiesList = (data as List)
          .map((json) => Company.fromJson(json))
          .toList();
      debugPrint(companiesList.toString());
      return CompanyResult(isSuccess: true, company: companiesList);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}
