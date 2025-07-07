// ignore_for_file: non_constant_identifier_names

import 'package:real_state_app/data/models/properties_model.dart';
import 'package:real_state_app/domain/entities/properites_entity.dart';
import 'package:real_state_app/domain/repositories/properites_repositories.dart';

class ProperitesUseCase {
  final ProperitesRepositories repositories;

  ProperitesUseCase(this.repositories);

  Future<ProperitesResult> call(ProperitesEntity entity) {
    return repositories.fethData(entity);
  }

  Future<List<PropertiesModel>> callData(String UUID) {
    return repositories.fetchingData(UUID);
  }
}
