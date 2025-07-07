// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/data/repositories/verify_code_repository_impl.dart';
import 'package:real_state_app/domain/usecases/verify_code_usecase.dart';
import 'package:real_state_app/presentation/bloc/verify_code_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:real_state_app/l10n/app_localizations.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BlocProvider(
      create: (_) => VerifyCodeBloc(
        verifyCodeUseCase: VerifyCodeUseCase(VerifyCodeRepositoryImpl()),
      ),
      child: isIOS
          ? BlocListener<VerifyCodeBloc, VerifyCodeState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  GoRouter.of(context).go('/uploadphoto-screen');
                }
              },
              child: CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  leading: GestureDetector(
                    onTap: () => context.go('/register-screen'),
                    child: const Icon(CupertinoIcons.back),
                  ),
                  middle: Text(
                    AppLocalizations.of(context)?.verifyCode ?? 'Verify Code',
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
                        child: BlocBuilder<VerifyCodeBloc, VerifyCodeState>(
                          builder: (context, state) {
                            final bloc = context.read<VerifyCodeBloc>();
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
                                  AppLocalizations.of(context)?.verifyCode ??
                                      'Verify Code',
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
                                      AppLocalizations.of(
                                        context,
                                      )?.verifyCode ??
                                      'Verify Code',
                                  icon: CupertinoIcons.mail,
                                  obscureText: false,
                                  hintText:
                                      AppLocalizations.of(
                                        context,
                                      )?.enterVerifyCode ??
                                      "Enter Your Verify Code",
                                  onChanged: (value) =>
                                      bloc.add(VerifyCodeChanged(value)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                            context,
                                          )?.enterVerifyCode ??
                                          "Enter Your Verify Code";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                CupertinoButton.filled(
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () async {
                                          final bloc = context
                                              .read<VerifyCodeBloc>();
                                          bloc.add(VerifyCodeProcess(context));
                                        },
                                  child: Text(
                                    AppLocalizations.of(context)?.confirm ??
                                        'Confirm',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (state.isSuccess)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      'Verifying E - mail successful!',
                                      style: TextStyle(
                                        color: CupertinoColors.activeGreen,
                                        fontFamily: 'SFProDisplay',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                if (state.isFailure)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      'Registration failed. Please try again.',
                                      style: TextStyle(
                                        color: CupertinoColors.destructiveRed,
                                        fontFamily: 'SFProDisplay',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
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
                    child: BlocBuilder<VerifyCodeBloc, VerifyCodeState>(
                      builder: (context, state) {
                        final bloc = context.read<VerifyCodeBloc>();
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
                              AppLocalizations.of(context)?.verifyCode ??
                                  'Verify Code',
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
                                  AppLocalizations.of(context)?.verifyCode ??
                                  "Verify Code",
                              icon: Icons.email_outlined,
                              obscureText: false,
                              hintText:
                                  AppLocalizations.of(
                                    context,
                                  )?.enterVerifyCode ??
                                  "Enter Your Verify Code",
                              onChanged: (value) =>
                                  bloc.add(VerifyCodeChanged(value)),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(
                                        context,
                                      )?.verifyCodeRequired ??
                                      "Verify Code Required";
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
                                onPressed: () {},
                                child: Text(
                                  AppLocalizations.of(context)?.confirm ??
                                      'Confirm',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
