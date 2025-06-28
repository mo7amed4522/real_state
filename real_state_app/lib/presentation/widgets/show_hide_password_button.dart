import 'package:flutter/material.dart';

class ShowHidePasswordButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;
  const ShowHidePasswordButton({
    super.key,
    required this.isVisible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: IconButton(
        key: ValueKey(isVisible),
        icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: onPressed,
      ),
    );
  }
}
