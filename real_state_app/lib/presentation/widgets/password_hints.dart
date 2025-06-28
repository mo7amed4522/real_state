import 'package:flutter/material.dart';

class PasswordHints extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  const PasswordHints({
    super.key,
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHint('At least 6 characters', hasMinLength),
        _buildHint('Contains uppercase', hasUppercase),
        _buildHint('Contains lowercase', hasLowercase),
      ],
    );
  }

  Widget _buildHint(String text, bool valid) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          color: valid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: valid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
