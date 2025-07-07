import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/core/assets/app_assets.dart';

// Events
abstract class PrivacyEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrivacyHtml extends PrivacyEvent {}

// States
abstract class PrivacyState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrivacyInitial extends PrivacyState {}

class PrivacyLoading extends PrivacyState {}

class PrivacyLoaded extends PrivacyState {
  final String html;
  PrivacyLoaded(this.html);
  @override
  List<Object?> get props => [html];
}

class PrivacyError extends PrivacyState {
  final String message;
  PrivacyError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  PrivacyBloc() : super(PrivacyInitial()) {
    on<LoadPrivacyHtml>((event, emit) async {
      emit(PrivacyLoading());
      try {
        // Simulate loading from local asset
        await Future.delayed(const Duration(milliseconds: 300));
        // The actual loading will be in the UI using rootBundle
        emit(PrivacyLoaded(AppAssets.termsPrivacy));
      } catch (e) {
        emit(PrivacyError(e.toString()));
      }
    });
  }
}
