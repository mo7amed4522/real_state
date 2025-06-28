// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Events
abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();
  @override
  List<Object?> get props => [];
}

class ForgotEmailChanged extends ForgotPasswordEvent {
  final String email;
  const ForgotEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class ForgotSendCodePressed extends ForgotPasswordEvent {}

// State
class ForgotPasswordState extends Equatable {
  final String email;
  final bool isEmailValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  const ForgotPasswordState({
    this.email = '',
    this.isEmailValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
  });

  ForgotPasswordState copyWith({
    String? email,
    bool? isEmailValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props => [
    email,
    isEmailValid,
    isSubmitting,
    isSuccess,
    isFailure,
  ];
}

// Bloc
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordState()) {
    on<ForgotEmailChanged>(_onEmailChanged);
    on<ForgotSendCodePressed>(_onSendCodePressed);
  }
  final emailController = TextEditingController();

  void _onEmailChanged(
    ForgotEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    final isEmailValid = _validateEmail(event.email);
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: isEmailValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onSendCodePressed(
    ForgotSendCodePressed event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    if (!state.isEmailValid) return;
    emit(
      state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false),
    );
    await Future.delayed(const Duration(seconds: 1));
    emit(state.copyWith(isSubmitting: false, isSuccess: true));
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^.+@.+\..+$');
    return emailRegex.hasMatch(email);
  }
}
