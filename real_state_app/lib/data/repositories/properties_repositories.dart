// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:real_state_app/data/models/properties_model.dart';
import 'package:real_state_app/domain/entities/properites_entity.dart';
import 'package:real_state_app/domain/repositories/properites_repositories.dart';

class PropertiesRepositories implements ProperitesRepositories {
  @override
  Future<ProperitesResult> fethData(ProperitesEntity entity) async {
    return ProperitesResult(isSuccess: true, properites: "");
  }

  @override
  Future<List<PropertiesModel>> fetchingData(String UUID) async {
    final response = await http.get(
      Uri.parse("http://localhost:3000/properties/by-company/$UUID"),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map<PropertiesModel>(
              (item) =>
                  PropertiesModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      } else if (data is Map) {
        // fallback if API returns a single object
        return [PropertiesModel.fromJson(Map<String, dynamic>.from(data))];
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch properties');
    }
  }
}
