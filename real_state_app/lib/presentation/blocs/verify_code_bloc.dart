// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:real_state_app/domain/entities/verified_email_entity.dart';
import 'package:real_state_app/domain/usecases/verify_code_usecase.dart';
import 'package:real_state_app/presentation/widgets/loader.dart';

// Events
abstract class VerifyCodeEvent extends Equatable {
  const VerifyCodeEvent();
  @override
  List<Object?> get props => [];
}

class VerifyCodeChanged extends VerifyCodeEvent {
  final String verifyCode;
  const VerifyCodeChanged(this.verifyCode);
  @override
  List<Object?> get props => [verifyCode];
}

class VerifyCodeProcess extends VerifyCodeEvent {
  final BuildContext context;
  const VerifyCodeProcess(this.context);
  @override
  List<Object?> get props => [context];
}

// State
class VerifyCodeState extends Equatable {
  final String verifyCode;
  final bool isCodeValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  const VerifyCodeState({
    this.verifyCode = '',
    this.isCodeValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
  });

  VerifyCodeState copyWith({
    String? verifyCode,
    bool? isCodeValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return VerifyCodeState(
      verifyCode: verifyCode ?? this.verifyCode,
      isCodeValid: isCodeValid ?? this.isCodeValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props => [
    verifyCode,
    isCodeValid,
    isSubmitting,
    isSuccess,
    isFailure,
  ];
}

// Bloc
class VerifyCodeBloc extends Bloc<VerifyCodeEvent, VerifyCodeState> {
  final VerifyCodeUseCase verifyCodeUseCase;
  VerifyCodeBloc({required this.verifyCodeUseCase})
    : super(const VerifyCodeState()) {
    on<VerifyCodeChanged>(_onVerifyCodeChanged);
    on<VerifyCodeProcess>(_onVerifyCodePressed);
  }
  final emailController = TextEditingController();

  void _onVerifyCodeChanged(
    VerifyCodeChanged event,
    Emitter<VerifyCodeState> emit,
  ) {
    final isCodeValid = _validateCode(event.verifyCode);
    emit(
      state.copyWith(
        verifyCode: event.verifyCode,
        isCodeValid: isCodeValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onVerifyCodePressed(
    VerifyCodeProcess event,
    Emitter<VerifyCodeState> emit,
  ) async {
    if (!state.isCodeValid) return;
    emit(
      state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false),
    );
    // Show loader
    Loader().lottieLoader(event.context);
    try {
      final entity = VerifiedEmailEntity(token: state.verifyCode);
      final result = await verifyCodeUseCase(entity);
      Future.microtask(() {
        if (event.context.mounted &&
            Navigator.of(event.context, rootNavigator: true).canPop()) {
          Navigator.of(event.context, rootNavigator: true).pop();
        }
      });
      debugPrint(result.isSuccess.toString());
      if (result.isSuccess) {
        emit(state.copyWith(isSubmitting: false, isSuccess: true));
      } else {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    } catch (e) {
      Future.microtask(() {
        if (event.context.mounted &&
            Navigator.of(event.context, rootNavigator: true).canPop()) {
          Navigator.of(event.context, rootNavigator: true).pop();
        }
      });
      emit(state.copyWith(isSubmitting: false, isFailure: true));
    }
  }

  bool _validateCode(String verifyCode) {
    final code = verifyCode.trim();
    if (code.isEmpty) return false;
    final hexRegex = RegExp(r'^[a-f0-9]{64}$');
    return hexRegex.hasMatch(code);
  }
}
