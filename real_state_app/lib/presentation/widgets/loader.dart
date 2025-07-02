import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:real_state_app/core/assets/app_assets.dart';

class Loader {
  Future<void> lottieLoader(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Lottie.asset(
            AppAssets.loadingAnimation,
            height: 100,
            width: 100,
          ),
        );
      },
      barrierLabel: '',
    );
  }

  Widget lottieWidget() {
    return Center(
      child: Lottie.asset(AppAssets.loadingAnimation, height: 100, width: 100),
    );
  }
}
