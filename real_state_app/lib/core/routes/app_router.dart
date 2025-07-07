// ignore_for_file: unused_import, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/constant/constatnt.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:real_state_app/presentation/views/register_view.dart';
import 'package:real_state_app/presentation/views/screens/chat_screen.dart';
import 'package:real_state_app/presentation/views/settings/edit_screen.dart';
import 'package:real_state_app/presentation/views/settings/privacy_screen.dart';
import 'package:real_state_app/presentation/views/settings/wallet_screen.dart';
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
    GoRoute(
      path: '/edit-screen',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/privcy-screen',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/wallet-screen',
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: '/conversation-screen',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const SizedBox.shrink();
        }
        return ConversationScreen(
          conversation: extra['conversation'],
          otherUser: extra['otherUser'],
          currentUserId: extra['currentUserId'],
          chatService: extra['chatService'],
        );
      },
    ),
  ],
  redirect: (context, state) async {
    final profile = await LocalStorage.getProfile();
    userData = profile;

    debugPrint(userData.toString());
    final isLoggingIn = state.matchedLocation == '/';
    if (profile != null && profile['id'] != null && isLoggingIn) {
      return '/home';
    }
    if (profile == null && !isLoggingIn) {
      return '/';
    }
    return null;
  },
);
