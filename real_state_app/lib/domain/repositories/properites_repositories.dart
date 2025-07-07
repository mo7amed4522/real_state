// ignore_for_file: non_constant_identifier_names

import 'package:real_state_app/data/models/properties_model.dart';
import 'package:real_state_app/domain/entities/properites_entity.dart';

abstract class ProperitesRepositories {
  Future<ProperitesResult> fethData(ProperitesEntity entity);
  Future<List<PropertiesModel>> fetchingData(String UUID);
}

class ProperitesResult {
  final bool isSuccess;
  final dynamic properites;
  final String? error;

  ProperitesResult({
    required this.isSuccess,
    required this.properites,
    this.error,
  });
}
