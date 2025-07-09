// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AnimatedTextFormFieldEvent extends Equatable {
  const AnimatedTextFormFieldEvent();
  @override
  List<Object?> get props => [];
}

class AnimatedTextChanged extends AnimatedTextFormFieldEvent {
  final String text;
  const AnimatedTextChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class AnimatedTextValidate extends AnimatedTextFormFieldEvent {
  final String? Function(String?)? validator;
  final String value;
  const AnimatedTextValidate(this.value, this.validator);
  @override
  List<Object?> get props => [value, validator];
}

class AnimatedTogglePasswordVisibility extends AnimatedTextFormFieldEvent {}

// State
class AnimatedTextFormFieldState extends Equatable {
  final String text;
  final String? errorText;
  final bool isPasswordField;
  final bool passwordVisible;

  const AnimatedTextFormFieldState({
    this.text = '',
    this.errorText,
    this.isPasswordField = false,
    this.passwordVisible = false,
  });

  AnimatedTextFormFieldState copyWith({
    String? text,
    String? errorText,
    bool? isPasswordField,
    bool? passwordVisible,
  }) {
    return AnimatedTextFormFieldState(
      text: text ?? this.text,
      errorText: errorText,
      isPasswordField: isPasswordField ?? this.isPasswordField,
      passwordVisible: passwordVisible ?? this.passwordVisible,
    );
  }

  @override
  List<Object?> get props =>
      [text, errorText, isPasswordField, passwordVisible];
}

// Bloc
class AnimatedTextFormFieldBloc
    extends Bloc<AnimatedTextFormFieldEvent, AnimatedTextFormFieldState> {
  AnimatedTextFormFieldBloc(
      {bool isPasswordField = false, bool passwordVisible = false})
      : super(AnimatedTextFormFieldState(
            isPasswordField: isPasswordField,
            passwordVisible: passwordVisible)) {
    on<AnimatedTextChanged>(_onTextChanged);
    on<AnimatedTextValidate>(_onValidate);
    on<AnimatedTogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  void _onTextChanged(
      AnimatedTextChanged event, Emitter<AnimatedTextFormFieldState> emit) {
    emit(state.copyWith(text: event.text, errorText: null));
  }

  void _onValidate(
      AnimatedTextValidate event, Emitter<AnimatedTextFormFieldState> emit) {
    final error = event.validator?.call(event.value);
    emit(state.copyWith(errorText: error));
  }

  void _onTogglePasswordVisibility(AnimatedTogglePasswordVisibility event,
      Emitter<AnimatedTextFormFieldState> emit) {
    emit(state.copyWith(passwordVisible: !state.passwordVisible));
  }
}
