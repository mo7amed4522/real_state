// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/presentation/blocs/forgot_password_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:real_state_app/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: isIOS
          ? CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: GestureDetector(
                  onTap: () => context.go('/'),
                  child: const Icon(CupertinoIcons.back),
                ),
                middle: Text(
                  AppLocalizations.of(context)?.forgotPassword ??
                      'Forgot Password',
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
                      child:
                          BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                            builder: (context, state) {
                              final bloc = context.read<ForgotPasswordBloc>();
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
                                    AppLocalizations.of(
                                          context,
                                        )?.forgotPassword ??
                                        'Forgot Password',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontFamily: '.SF Pro Text',
                                      color: CupertinoColors.label,
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
                                    hintText: 'Enter your email',
                                    onChanged: (value) =>
                                        bloc.add(ForgotEmailChanged(value)),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),
                                  CupertinoButton.filled(
                                    onPressed: () =>
                                        bloc.add(ForgotSendCodePressed()),
                                    child: Text(
                                      'Send Reset Link',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  CupertinoButton(
                                    onPressed: () => context.go('/login'),
                                    child: Text(
                                      'Back to Login',
                                      style: const TextStyle(fontSize: 16),
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
                    child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                      builder: (context, state) {
                        final bloc = context.read<ForgotPasswordBloc>();
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
                              AppLocalizations.of(context)?.forgotPassword ??
                                  'Forgot Password',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
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
                                  bloc.add(ForgotEmailChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
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
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    bloc.add(ForgotSendCodePressed()),
                                child: const Text('Send Reset Link'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text(
                                'Back to Login',
                                style: TextStyle(fontSize: 16),
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
