import 'package:real_state_app/domain/entities/comapnies.dart';
import 'package:real_state_app/domain/repositories/company_repositories.dart';

class CompaniesUseCase {
  final CompanyRepositories repository;

  CompaniesUseCase(this.repository);

  Future<CompanyResult> call(ComapniesEnitity entity) {
    return repository.fetchData(entity);
  }
}
