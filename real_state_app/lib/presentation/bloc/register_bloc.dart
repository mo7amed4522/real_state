// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:real_state_app/domain/entities/register_entity.dart';
import 'package:real_state_app/domain/usecases/register_usecase.dart';

import 'package:real_state_app/presentation/widgets/loader.dart';

// Events
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object?> get props => [];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;
  const RegisterEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;
  const RegisterPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class RegisterConfirmPasswordChanged extends RegisterEvent {
  final String confirmPassword;
  const RegisterConfirmPasswordChanged(this.confirmPassword);
  @override
  List<Object?> get props => [confirmPassword];
}

class RegisterFirstNameChanged extends RegisterEvent {
  final String firstName;
  const RegisterFirstNameChanged(this.firstName);
  @override
  List<Object?> get props => [firstName];
}

class RegisterLastNameChanged extends RegisterEvent {
  final String lastName;
  const RegisterLastNameChanged(this.lastName);
  @override
  List<Object?> get props => [lastName];
}

class RegisterPhoneChanged extends RegisterEvent {
  final String phone;
  const RegisterPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class RegisterCountryCodeChanged extends RegisterEvent {
  final String countryCode;
  final String dialCode;
  const RegisterCountryCodeChanged(this.countryCode, this.dialCode);
  @override
  List<Object?> get props => [countryCode, dialCode];
}

class RegisterSubmitted extends RegisterEvent {
  final BuildContext context;
  const RegisterSubmitted(this.context);
  @override
  List<Object?> get props => [context];
}

class ToggleRegisterPasswordVisibility extends RegisterEvent {}

// State
class RegisterState extends Equatable {
  final String firstName;
  final String lastName;
  final String phone;
  final String countryCode;
  final String dialCode;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool showPassword;

  const RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.countryCode = 'US',
    this.dialCode = '+1',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isConfirmPasswordValid = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.showPassword = false,
  });

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? countryCode,
    String? dialCode,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordValid,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? showPassword,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid:
          isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      showPassword: showPassword ?? this.showPassword,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    countryCode,
    dialCode,
    email,
    password,
    confirmPassword,
    isEmailValid,
    isPasswordValid,
    isConfirmPasswordValid,
    isSubmitting,
    isSuccess,
    isFailure,
    showPassword,
  ];
}

// Bloc

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;
  RegisterBloc({required this.registerUseCase}) : super(const RegisterState()) {
    on<RegisterFirstNameChanged>(_onFirstNameChanged);
    on<RegisterLastNameChanged>(_onLastNameChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterCountryCodeChanged>(_onCountryCodeChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterSubmitted>(_onSubmitted);
    on<ToggleRegisterPasswordVisibility>(_onTogglePasswordVisibility);
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    final email = event.email;
    final isEmailValid = _validateEmail(email) == null;
    emit(
      state.copyWith(
        email: event.email,
        isEmailValid: isEmailValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final isPasswordValid = _validatePassword(event.password);
    emit(
      state.copyWith(
        password: event.password,
        isPasswordValid: isPasswordValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    final isConfirmPasswordValid =
        event.confirmPassword == state.password &&
        event.confirmPassword.isNotEmpty;
    emit(
      state.copyWith(
        confirmPassword: event.confirmPassword,
        isConfirmPasswordValid: isConfirmPasswordValid,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onFirstNameChanged(
    RegisterFirstNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        firstName: event.firstName,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onLastNameChanged(
    RegisterLastNameChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        lastName: event.lastName,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(phone: event.phone, isFailure: false, isSuccess: false),
    );
  }

  void _onCountryCodeChanged(
    RegisterCountryCodeChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        countryCode: event.countryCode,
        dialCode: event.dialCode,
        isFailure: false,
        isSuccess: false,
      ),
    );
  }

  void _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.firstName.isEmpty ||
        state.lastName.isEmpty ||
        state.phone.isEmpty ||
        state.email.isEmpty ||
        !state.isPasswordValid) {
      return;
    }
    emit(
      state.copyWith(isSubmitting: true, isFailure: false, isSuccess: false),
    );
    // Show loader
    Loader().lottieLoader(event.context);
    try {
      final entity = RegisterEntity(
        email: state.email,
        password: state.password,
        firstName: state.firstName,
        lastName: state.lastName,
        phone: state.dialCode + state.phone,
        role: 'buyer',
        company: 'FREE',
        licenseNumber: 'LIC123456',
      );
      final result = await registerUseCase(entity);
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

  void _onTogglePasswordVisibility(
    ToggleRegisterPasswordVisibility event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  bool _validatePassword(String password) {
    return password.length >= 6;
  }
}
