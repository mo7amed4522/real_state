// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimatedTextFormField extends ConsumerStatefulWidget {
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
  ConsumerState<AnimatedTextFormField> createState() =>
      _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends ConsumerState<AnimatedTextFormField> {
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPassword = widget.isPasswordField ?? false;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: isPassword
          ? !(widget.passwordVisible ?? false)
          : widget.obscureText,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isDark
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onBackground,
      ),
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(
          widget.icon,
          color: isDark ? theme.colorScheme.outline : theme.colorScheme.primary,
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: _focusNode.hasFocus || widget.controller.text.isNotEmpty
              ? theme.colorScheme.primary
              : (isDark
                    ? theme.colorScheme.onSurface.withOpacity(0.7)
                    : theme.colorScheme.onBackground.withOpacity(0.7)),
        ),
        floatingLabelStyle: TextStyle(color: theme.colorScheme.primary),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: isDark
              ? theme.colorScheme.onSurface.withOpacity(0.5)
              : theme.colorScheme.onBackground.withOpacity(0.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 14,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (widget.passwordVisible ?? false)
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: isDark
                      ? theme.colorScheme.outline
                      : theme.colorScheme.primary,
                ),
                onPressed: widget.onTogglePasswordVisibility,
              )
            : widget.suffix,
        errorText: _errorText,
        filled: true,
        fillColor: isDark ? theme.colorScheme.surface : Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        final error = widget.validator?.call(value);
        setState(() => _errorText = error);
        return error;
      },
      onChanged: (value) {
        final error = widget.validator?.call(value);
        setState(() => _errorText = error);
        widget.onChanged?.call(value);
      },
    );
  }
}
