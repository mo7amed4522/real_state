import 'package:real_state_app/domain/entities/comapnies.dart';

abstract class CompanyRepositories {
  Future<CompanyResult> fetchData(ComapniesEnitity entity);
}

class CompanyResult {
  final bool isSuccess;
  final dynamic company;
  final String? error;

  const CompanyResult({
    required this.isSuccess,
    required this.company,
    this.error,
  });
}
