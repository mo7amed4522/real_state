// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Events
abstract class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => [];
}

class EmailChanged extends LoginEvent {
  final String email;
  const EmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChanged extends LoginEvent {
  final String password;
  const PasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {}

class TogglePasswordVisibility extends LoginEvent {}

// State
class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isFormValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool showPassword;
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isFormValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.showPassword = false,
    this.hasMinLength = false,
    this.hasUppercase = false,
    this.hasLowercase = false,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isFormValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? showPassword,
    bool? hasMinLength,
    bool? hasUppercase,
    bool? hasLowercase,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isFormValid: isFormValid ?? this.isFormValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      showPassword: showPassword ?? this.showPassword,
      hasMinLength: hasMinLength ?? this.hasMinLength,
      hasUppercase: hasUppercase ?? this.hasUppercase,
      hasLowercase: hasLowercase ?? this.hasLowercase,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isEmailValid,
    isPasswordValid,
    isFormValid,
    isSubmitting,
    isSuccess,
    isFailure,
    showPassword,
    hasMinLength,
    hasUppercase,
    hasLowercase,
  ];
}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    final isEmailValid = _validateEmail(event.email);
    final isFormValid = isEmailValid && state.isPasswordValid;
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: isEmailValid,
        isFormValid: isFormValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final hasMinLength = event.password.length >= 6;
    final hasUppercase = event.password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = event.password.contains(RegExp(r'[a-z]'));
    final isPasswordValid = hasMinLength && hasUppercase && hasLowercase;
    final isFormValid = state.isEmailValid && isPasswordValid;
    emit(
      state.copyWith(
        password: event.password,
        isPasswordValid: isPasswordValid,
        isFormValid: isFormValid,
        hasMinLength: hasMinLength,
        hasUppercase: hasUppercase,
        hasLowercase: hasLowercase,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isFormValid) return;
    emit(
      state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false),
    );
    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));
    // Here you would call your repository/auth API
    // For now, always succeed
    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^.+@.+\..+$');
    return emailRegex.hasMatch(email);
  }
}
