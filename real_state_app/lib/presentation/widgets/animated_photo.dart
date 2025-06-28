import 'package:flutter/material.dart';

class AnimatedPhoto extends StatefulWidget {
  final String imageAsset;
  final double height;
  const AnimatedPhoto({super.key, required this.imageAsset, this.height = 120});

  @override
  State<AnimatedPhoto> createState() => _AnimatedPhotoState();
}

class _AnimatedPhotoState extends State<AnimatedPhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Image.asset(widget.imageAsset, height: widget.height),
    );
  }
}
