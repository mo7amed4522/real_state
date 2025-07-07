// ignore_for_file: empty_constructor_bodies, unused_local_variable
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/data/models/company.dart';
import 'package:real_state_app/data/models/properties_model.dart';
import 'package:real_state_app/domain/entities/comapnies.dart';
import 'package:real_state_app/domain/usecases/companies_usecase.dart';
import 'package:real_state_app/domain/usecases/properites_usease.dart';

// =============== EVENT ============== //
abstract class HomeWidgetEvent extends Equatable {
  const HomeWidgetEvent();

  @override
  List<Object?> get props => [];
}

class FetchCompanies extends HomeWidgetEvent {}

class SelectCompany extends HomeWidgetEvent {
  final String companyId;
  const SelectCompany(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

class FetchProperties extends HomeWidgetEvent {
  final String companyId;
  const FetchProperties(this.companyId);

  @override
  List<Object?> get props => [companyId];
}

// ============== STATE =================== //
abstract class HomeWidgetState extends Equatable {
  const HomeWidgetState();

  @override
  List<Object?> get props => [];
}

class HomeWidgetInitial extends HomeWidgetState {}

class HomeWidgetLoading extends HomeWidgetState {}

class CompaniesLoaded extends HomeWidgetState {
  final List<Company> companies;
  final String? selectedCompanyId;
  const CompaniesLoaded(this.companies, {this.selectedCompanyId});

  CompaniesLoaded copyWith({String? selectedCompanyId}) {
    return CompaniesLoaded(
      companies,
      selectedCompanyId: selectedCompanyId ?? this.selectedCompanyId,
    );
  }

  @override
  List<Object?> get props => [companies, selectedCompanyId];
}

class PropertiesLoaded extends HomeWidgetState {
  final List<Company> companies;
  final String? selectedCompanyId;
  final List<PropertiesModel> properties;
  const PropertiesLoaded({
    required this.companies,
    required this.selectedCompanyId,
    required this.properties,
  });

  @override
  List<Object?> get props => [companies, selectedCompanyId, properties];
}

class CompaniesError extends HomeWidgetState {
  final String message;
  const CompaniesError(this.message);

  @override
  List<Object?> get props => [message];
}

class PropertiesError extends HomeWidgetState {
  final String message;
  const PropertiesError(this.message);

  @override
  List<Object?> get props => [message];
}
// ================== BLOC =================== //

class HomeWidgetBloc extends Bloc<HomeWidgetEvent, HomeWidgetState> {
  final CompaniesUseCase companiesUseCase;
  final ProperitesUseCase propertiesUseCase;
  HomeWidgetBloc({
    required this.companiesUseCase,
    required this.propertiesUseCase,
  }) : super(HomeWidgetInitial()) {
    // Map Events to States
    on<FetchCompanies>(_onFetchCompanies);
    on<SelectCompany>(_onSelectCompany);
    on<FetchProperties>(_onFetchProperties);
  }

  Future<void> _onFetchCompanies(
    FetchCompanies event,
    Emitter<HomeWidgetState> emit,
  ) async {
    try {
      emit(HomeWidgetLoading());
      final result = await companiesUseCase.call(
        ComapniesEnitity(
          id: '',
          name: '',
          website: '',
          phone: '',
          address: '',
          logoUrl: '',
          logoFileName: '',
          createdAt: '',
          updatedAt: '',
        ),
      );
      if (result.isSuccess) {
        final List<Company> companies = result.company as List<Company>;
        emit(CompaniesLoaded(companies));
      } else {
        emit(CompaniesError(result.error ?? "Unknown error"));
      }
    } catch (e) {
      emit(CompaniesError(e.toString()));
    }
  }

  Future<void> _onSelectCompany(
    SelectCompany event,
    Emitter<HomeWidgetState> emit,
  ) async {
    final state = this.state;
    if (state is CompaniesLoaded) {
      emit(state.copyWith(selectedCompanyId: event.companyId));
    } else if (state is PropertiesLoaded) {
      emit(
        PropertiesLoaded(
          companies: state.companies,
          selectedCompanyId: event.companyId,
          properties: state.properties,
        ),
      );
    }
  }

  Future<void> _onFetchProperties(
    FetchProperties event,
    Emitter<HomeWidgetState> emit,
  ) async {
    try {
      final state = this.state;
      List<Company> companies = [];
      String? selectedCompanyId;
      if (state is CompaniesLoaded) {
        companies = state.companies;
        selectedCompanyId = state.selectedCompanyId;
      } else if (state is PropertiesLoaded) {
        companies = state.companies;
        selectedCompanyId = state.selectedCompanyId;
      }
      // Fetch properties by company ID
      final List<PropertiesModel> properties = await propertiesUseCase.callData(
        event.companyId,
      );
      emit(
        PropertiesLoaded(
          companies: companies,
          selectedCompanyId: event.companyId,
          properties: properties,
        ),
      );
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }
}
