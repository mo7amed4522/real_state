// ignore_for_file: unused_import

import 'package:go_router/go_router.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:real_state_app/presentation/views/register_view.dart';
import 'package:real_state_app/presentation/views/upload_photo.dart';
import 'package:real_state_app/presentation/views/verifiy_code_view.dart';
import '../../presentation/views/home_view.dart';
import '../../presentation/views/login_view.dart';
import '../../presentation/views/forgot_password_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeView()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/register-screen',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-screen',
      builder: (context, state) => const VerifyCodeScreen(),
    ),
    GoRoute(
      path: '/uploadphoto-screen',
      builder: (context, state) => const UploadPhotoScreen(),
    ),
  ],
  redirect: (context, state) async {
    final profile = await LocalStorage.getProfile();
    final isLoggingIn = state.matchedLocation == '/';
    if (profile != null && isLoggingIn) {
      return '/home';
    }
    if (profile == null && !isLoggingIn) {
      return '/';
    }
    return null;
  },
);
