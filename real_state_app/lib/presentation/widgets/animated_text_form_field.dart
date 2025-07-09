// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/animated_text_form_field_bloc.dart';

class AnimatedTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool? isPasswordField;
  final bool? passwordVisible;
  final VoidCallback? onTogglePasswordVisibility;

  const AnimatedTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.suffix,
    this.hintText,
    this.keyboardType,
    this.enabled = true,
    this.isPasswordField = false,
    this.passwordVisible,
    this.onTogglePasswordVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimatedTextFormFieldBloc>(
      create: (_) => AnimatedTextFormFieldBloc(
        isPasswordField: isPasswordField ?? false,
        passwordVisible: passwordVisible ?? false,
      ),
      child: BlocBuilder<AnimatedTextFormFieldBloc, AnimatedTextFormFieldState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final bloc = context.read<AnimatedTextFormFieldBloc>();
          return TextFormField(
            controller: controller,
            obscureText:
                state.isPasswordField ? !state.passwordVisible : obscureText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onBackground,
            ),
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: isDark
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
              ),
              labelText: labelText,
              labelStyle: TextStyle(
                color: controller.text.isNotEmpty || state.text.isNotEmpty
                    ? theme.colorScheme.primary
                    : (isDark
                        ? theme.colorScheme.onSurface.withOpacity(0.7)
                        : theme.colorScheme.onBackground.withOpacity(0.7)),
              ),
              floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ),
              suffixIcon: state.isPasswordField
                  ? IconButton(
                      icon: Icon(
                        state.passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark
                            ? theme.colorScheme.outline
                            : theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        bloc.add(AnimatedTogglePasswordVisibility());
                        onTogglePasswordVisibility?.call();
                      },
                    )
                  : suffix,
              errorText: state.errorText,
              filled: true,
              fillColor: isDark ? theme.colorScheme.surface : Colors.white,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            validator: (value) {
              bloc.add(AnimatedTextValidate(value ?? '', validator));
              return state.errorText;
            },
            onChanged: (value) {
              bloc.add(AnimatedTextChanged(value));
              if (validator != null) {
                bloc.add(AnimatedTextValidate(value, validator));
              }
              onChanged?.call(value);
            },
          );
        },
      ),
    );
  }
}
