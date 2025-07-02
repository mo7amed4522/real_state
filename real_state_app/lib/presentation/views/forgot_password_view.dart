// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/presentation/blocs/forgot_password_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:real_state_app/l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final theme = Theme.of(context);
    final cupertinoTheme = CupertinoTheme.of(context);

    final backgroundColor = isIOS
        ? cupertinoTheme.scaffoldBackgroundColor
        : theme.colorScheme.background;

    final onBackground = isIOS
        ? cupertinoTheme.textTheme.textStyle.color
        : theme.colorScheme.onBackground;

    return BlocProvider(
      create: (_) => ForgotPasswordBloc(),
      child: PlatformScaffold(
        backgroundColor: backgroundColor,
        appBar: PlatformAppBar(
          title: Text(
            AppLocalizations.of(context)?.forgotPassword ?? 'Forgot Password',
            style: TextStyle(color: onBackground, fontWeight: FontWeight.bold),
          ),
          material: (_, __) => MaterialAppBarData(
            backgroundColor: backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: onBackground),
          ),
          cupertino: (_, __) => CupertinoNavigationBarData(
            backgroundColor: backgroundColor,
            border: null,
            previousPageTitle: '',
          ),
          leading: PlatformIconButton(
            icon: Icon(
              isIOS ? CupertinoIcons.back : Icons.arrow_back,
              //color: onBackground,
            ),
            onPressed: () {
              Future.microtask(() {
                if (context.mounted &&
                    Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
              });
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Material(
                  color: Colors.transparent,
                  child: BlocBuilder<ForgotPasswordBloc, ForgotPasswordState>(
                    builder: (context, state) {
                      final bloc = context.read<ForgotPasswordBloc>();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          AnimatedPhoto(
                            imageAsset: AppAssets.logoApp,
                            height: 100,
                          ),
                          const SizedBox(height: 24),
                          // Title
                          Text(
                            AppLocalizations.of(context)?.forgotPassword ??
                                'Forgot Password',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Email Field
                          AnimatedTextFormField(
                            controller: bloc.emailController,
                            labelText:
                                AppLocalizations.of(context)?.email ?? 'Email',
                            icon: Icons.email_outlined,
                            hintText:
                                AppLocalizations.of(context)?.email ??
                                'Enter your email',
                            obscureText: false,
                            onChanged: (value) =>
                                bloc.add(ForgotEmailChanged(value)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(
                                      context,
                                    )?.emailRequired ??
                                    'Email required';
                              }
                              final emailRegex = RegExp(r'^.+@.+\..+$');
                              if (!emailRegex.hasMatch(value)) {
                                return AppLocalizations.of(
                                      context,
                                    )?.enterValidEmail ??
                                    'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          // Send Code Button
                          PlatformElevatedButton(
                            onPressed: state.isEmailValid && !state.isSubmitting
                                ? () => bloc.add(ForgotSendCodePressed())
                                : null,
                            child: state.isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)?.sendCode ??
                                        'Send Code',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                            material: (_, __) => MaterialElevatedButtonData(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.isEmailValid
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            cupertino: (_, __) => CupertinoElevatedButtonData(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
