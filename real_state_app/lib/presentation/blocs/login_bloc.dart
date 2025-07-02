// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously, must_be_immutable

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:real_state_app/data/repositories/auth_repository_impl.dart';
import 'package:real_state_app/domain/entities/user_entity.dart';
import 'package:real_state_app/domain/usecases/login_usecase.dart';
import 'package:real_state_app/presentation/widgets/loader.dart';

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

class LoginSubmitted extends LoginEvent {
  final BuildContext context;
  const LoginSubmitted(this.context);
  @override
  List<Object?> get props => [context];
}

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
  final LoginUseCase loginUseCase;
  LoginBloc({required this.loginUseCase}) : super(LoginState()) {
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
    Loader().lottieLoader(event.context);
    try {
      final entity = UserEntity(email: state.email, password: state.password);
      final result = await loginUseCase(entity);
      Future.microtask(() {
        if (event.context.mounted &&
            Navigator.of(event.context, rootNavigator: true).canPop()) {
          Navigator.of(event.context, rootNavigator: true).pop();
        }
      });
      if (result.isSuccess) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
        if (result.status == "pending_verification") {
          event.context.go('/verify-screen');
        } else if (result.status == "active") {
          final authRepo = AuthRepositoryImpl();
          final profile = await authRepo.getOwnProfile(result.token!);
          await LocalStorage.saveProfile(jsonEncode(profile.toJson()));
          event.context.go('/home');
        } else {
          final isIOS = Theme.of(event.context).platform == TargetPlatform.iOS;
          if (isIOS) {
            showCupertinoDialog(
              context: event.context,
              builder: (context) => CupertinoAlertDialog(
                title: Text('Login Failed'),
                content: Text('Login failed. Please try again.'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(event.context).showSnackBar(
              SnackBar(
                content: Text('Login failed. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    } catch (e) {
      Future.microtask(() {
        if (event.context.mounted &&
            Navigator.of(event.context, rootNavigator: true).canPop()) {
          Navigator.of(event.context, rootNavigator: true).pop();
        }
        final isIOS = Theme.of(event.context).platform == TargetPlatform.iOS;
        if (isIOS) {
          showCupertinoDialog(
            context: event.context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Login Failed'),
              content: Text('Login failed. Please try again.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(event.context).showSnackBar(
            SnackBar(
              content: Text('Login failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      emit(state.copyWith(isSubmitting: false, isFailure: true));
    }
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
