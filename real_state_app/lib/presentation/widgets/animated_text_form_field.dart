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
    final isPassword = widget.isPasswordField ?? false;
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: isPassword ? !(widget.passwordVisible ?? false) : widget.obscureText,
      style: theme.textTheme.bodyLarge,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: Colors.grey),
        labelText: widget.labelText,
        hintText: widget.hintText,
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
                  color: Colors.grey,
                ),
                onPressed: widget.onTogglePasswordVisibility,
              )
            : widget.suffix,
        errorText: _errorText,
        filled: true,
        fillColor: Colors.white,
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
