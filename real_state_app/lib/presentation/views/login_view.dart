// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/data/repositories/auth_repository_impl.dart';
import 'package:real_state_app/domain/usecases/login_usecase.dart';
import 'package:real_state_app/presentation/blocs/login_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BlocProvider(
      create: (_) =>
          LoginBloc(loginUseCase: LoginUseCase(AuthRepositoryImpl())),
      child: isIOS
          ? CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text(
                  AppLocalizations.of(context)?.appTitle ?? 'Real Estate App',
                  style: const TextStyle(fontFamily: 'SFProDisplay'),
                ),
                backgroundColor: CupertinoColors.systemBackground,
                border: null,
              ),
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final bloc = context.read<LoginBloc>();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 32),
                              Center(
                                child: AnimatedPhoto(
                                  imageAsset: AppAssets.logoApp,
                                  height: 150,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)?.welcome ??
                                    'Welcome Back',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  fontFamily: 'SFProDisplay',
                                  color:
                                      CupertinoTheme.of(context).brightness ==
                                          Brightness.dark
                                      ? CupertinoColors.white
                                      : CupertinoColors.label,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              AnimatedTextFormField(
                                controller: bloc.emailController,
                                labelText:
                                    AppLocalizations.of(context)?.email ??
                                    'Email',
                                icon: CupertinoIcons.mail,
                                obscureText: false,
                                hintText:
                                    AppLocalizations.of(
                                      context,
                                    )?.enterValidEmail ??
                                    "Enter your E-mail",
                                onChanged: (value) =>
                                    bloc.add(EmailChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                          context,
                                        )?.emailRequired ??
                                        "E-mail is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              AnimatedTextFormField(
                                controller: bloc.passwordController,
                                labelText:
                                    AppLocalizations.of(context)?.password ??
                                    'Password',
                                icon: CupertinoIcons.lock,
                                isPasswordField: true,
                                passwordVisible: state.showPassword,
                                onTogglePasswordVisibility: () =>
                                    bloc.add(TogglePasswordVisibility()),
                                hintText:
                                    AppLocalizations.of(
                                      context,
                                    )?.enterPassword ??
                                    "Enter your Password",
                                onChanged: (value) =>
                                    bloc.add(PasswordChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppLocalizations.of(
                                          context,
                                        )?.passwordRequired ??
                                        "Password required";
                                  }
                                  return null;
                                },
                              ),
                              PasswordHints(
                                hasMinLength:
                                    bloc.passwordController.text.length >= 6,
                                hasUppercase: RegExp(
                                  r'[A-Z]',
                                ).hasMatch(bloc.passwordController.text),
                                hasLowercase: RegExp(
                                  r'[a-z]',
                                ).hasMatch(bloc.passwordController.text),
                              ),
                              const SizedBox(height: 32),
                              CupertinoButton.filled(
                                onPressed: () =>
                                    bloc.add(LoginSubmitted(context)),
                                child: Text(
                                  AppLocalizations.of(context)?.login ??
                                      'Login',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SFProDisplay',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              CupertinoButton(
                                onPressed: () => context.go('/forgot-password'),
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.forgotPassword ??
                                      'Forgot Password?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'SFProDisplay',
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                onPressed: () => context.go('/register-screen'),
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.doNotHaveAccount ??
                                      "Don't have an account? Register",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'SFProDisplay',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/'),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        final bloc = context.read<LoginBloc>();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: AnimatedPhoto(
                                imageAsset: AppAssets.logoApp,
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              AppLocalizations.of(context)?.welcome ??
                                  'Welcome Back',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    fontFamily: 'SFProDisplay',
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            AnimatedTextFormField(
                              controller: bloc.emailController,
                              labelText:
                                  AppLocalizations.of(context)?.email ??
                                  'Email',
                              icon: Icons.email_outlined,
                              obscureText: false,
                              hintText: 'Enter your email',
                              onChanged: (value) =>
                                  bloc.add(EmailChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            AnimatedTextFormField(
                              controller: bloc.passwordController,
                              labelText:
                                  AppLocalizations.of(context)?.password ??
                                  'Password',
                              icon: Icons.lock_outline,
                              isPasswordField: true,
                              passwordVisible: state.showPassword,
                              onTogglePasswordVisibility: () =>
                                  bloc.add(TogglePasswordVisibility()),
                              hintText: 'Enter your password',
                              onChanged: (value) =>
                                  bloc.add(PasswordChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                            ),
                            PasswordHints(
                              hasMinLength:
                                  bloc.passwordController.text.length >= 6,
                              hasUppercase: RegExp(
                                r'[A-Z]',
                              ).hasMatch(bloc.passwordController.text),
                              hasLowercase: RegExp(
                                r'[a-z]',
                              ).hasMatch(bloc.passwordController.text),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SFProDisplay',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    bloc.add(LoginSubmitted(context)),
                                child: Text(
                                  AppLocalizations.of(context)?.login ??
                                      'Login',
                                  style: const TextStyle(
                                    fontFamily: 'SFProDisplay',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => context.go('/forgot-password'),
                              child: Text(
                                AppLocalizations.of(context)?.forgotPassword ??
                                    'Forgot Password?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SFProDisplay',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.go('/register-screen'),
                              child: Text(
                                AppLocalizations.of(context)?.register ??
                                    "Don't have an account? Register",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'SFProDisplay',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

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
        const SizedBox(height: 8),
        Text(
          'Password must contain:',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground,
            fontFamily: 'SFProDisplay',
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              hasMinLength ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: hasMinLength
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onBackground,
            ),
            const SizedBox(width: 8),
            Text(
              'At least 6 characters',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: 'SFProDisplay',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              hasUppercase ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: hasUppercase
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onBackground,
            ),
            const SizedBox(width: 8),
            Text(
              'Uppercase letter',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: 'SFProDisplay',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              hasLowercase ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: hasLowercase
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onBackground,
            ),
            const SizedBox(width: 8),
            Text(
              'Lowercase letter',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
                fontFamily: 'SFProDisplay',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
