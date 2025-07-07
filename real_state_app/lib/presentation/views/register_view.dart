// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/data/repositories/register_repository_impl.dart';
import 'package:real_state_app/domain/usecases/register_usecase.dart';
import 'package:real_state_app/presentation/bloc/register_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_photo.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:real_state_app/l10n/app_localizations.dart';
import 'package:real_state_app/presentation/widgets/searchable_country_code_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    _setInitialCountryByLocation();
  }

  Future<void> _setInitialCountryByLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final List<dynamic> countryCodes = json.decode(
        await rootBundle.loadString(AppAssets.countryCode),
      );
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final countryCode = placemarks.first.isoCountryCode;
      final country = countryCodes.firstWhere(
        (c) => c['code'] == countryCode,
        orElse: () => null,
      );
      if (country != null && mounted) {
        final bloc = context.read<RegisterBloc>();
        bloc.add(
          RegisterCountryCodeChanged(country['code'], country['dial_code']),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final cupertinoTheme = CupertinoTheme.of(context);
    final materialTheme = Theme.of(context);
    return BlocProvider(
      create: (_) => RegisterBloc(
        registerUseCase: RegisterUseCase(RegisterRepositoryImpl()),
      ),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.isSuccess) {
            GoRouter.of(context).go('/verify-screen');
          }
        },
        child: isIOS
            ? CupertinoPageScaffold(
                navigationBar: CupertinoNavigationBar(
                  leading: GestureDetector(
                    onTap: () {
                      Future.microtask(() {
                        if (context.mounted &&
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).canPop()) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      });
                    },
                    child: const Icon(CupertinoIcons.back),
                  ),
                  middle: Text(
                    AppLocalizations.of(context)?.register ?? 'Register',
                    style: TextStyle(
                      color: cupertinoTheme.brightness == Brightness.dark
                          ? CupertinoColors.white
                          : CupertinoColors.label,
                    ),
                  ),
                  backgroundColor: CupertinoColors.systemBackground,
                  border: null,
                ),
                child: SafeArea(
                  child: ScaffoldMessenger(
                    child: Material(
                      color: Colors.transparent,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: BlocBuilder<RegisterBloc, RegisterState>(
                            builder: (context, state) {
                              final bloc = context.read<RegisterBloc>();
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AnimatedPhoto(
                                    imageAsset: AppAssets.logoApp,
                                    height: 100,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    AppLocalizations.of(context)?.register ??
                                        'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      fontFamily: '.SF Pro Text',
                                      color:
                                          cupertinoTheme.brightness ==
                                              Brightness.dark
                                          ? CupertinoColors.white
                                          : CupertinoColors.label,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  AnimatedTextFormField(
                                    controller: bloc.firstNameController,
                                    labelText:
                                        AppLocalizations.of(
                                          context,
                                        )?.firstName ??
                                        'First Name',
                                    icon: CupertinoIcons.person,
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )?.enterFirstName ??
                                        'Enter your first name',
                                    obscureText: false,
                                    onChanged: (value) => bloc.add(
                                      RegisterFirstNameChanged(value),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(
                                              context,
                                            )?.firstNameRequired ??
                                            'First name required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedTextFormField(
                                    controller: bloc.lastNameController,
                                    labelText:
                                        AppLocalizations.of(
                                          context,
                                        )?.lastName ??
                                        'Last Name',
                                    icon: CupertinoIcons.person,
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )?.enterLastName ??
                                        'Enter your last name',
                                    obscureText: false,
                                    onChanged: (value) => bloc.add(
                                      RegisterLastNameChanged(value),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(
                                              context,
                                            )?.lastNameRequired ??
                                            'Last name required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedTextFormField(
                                    controller: bloc.emailController,
                                    labelText:
                                        AppLocalizations.of(context)?.email ??
                                        'Email',
                                    icon: CupertinoIcons.mail,
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )?.enterValidEmail ??
                                        'Enter your email',
                                    obscureText: false,
                                    onChanged: (value) =>
                                        bloc.add(RegisterEmailChanged(value)),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: SearchableCountryCodeDropdown(
                                          selectedCode: state.countryCode,
                                          selectedDialCode: state.dialCode,
                                          onChanged: (country) {
                                            bloc.add(
                                              RegisterCountryCodeChanged(
                                                country.code,
                                                country.dialCode,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: AnimatedTextFormField(
                                          controller: bloc.phoneController,
                                          labelText:
                                              AppLocalizations.of(
                                                context,
                                              )?.phone ??
                                              'Phone',
                                          icon: CupertinoIcons.phone,
                                          hintText:
                                              AppLocalizations.of(
                                                context,
                                              )?.enterPhone ??
                                              'Enter your phone or search country',
                                          obscureText: false,
                                          onChanged: (value) => bloc.add(
                                            RegisterPhoneChanged(value),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(
                                                    context,
                                                  )?.phoneRequired ??
                                                  'Phone required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AnimatedTextFormField(
                                    controller: bloc.passwordController,
                                    labelText:
                                        AppLocalizations.of(
                                          context,
                                        )?.password ??
                                        'Password',
                                    icon: CupertinoIcons.lock,
                                    isPasswordField: true,
                                    passwordVisible: state.showPassword,
                                    onTogglePasswordVisibility: () => bloc.add(
                                      ToggleRegisterPasswordVisibility(),
                                    ),
                                    hintText:
                                        AppLocalizations.of(
                                          context,
                                        )?.enterPassword ??
                                        'Enter your password',
                                    onChanged: (value) => bloc.add(
                                      RegisterPasswordChanged(value),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(
                                              context,
                                            )?.passwordRequired ??
                                            'Password required';
                                      }
                                      if (!state.isPasswordValid) {
                                        return AppLocalizations.of(
                                              context,
                                            )?.passwordShort ??
                                            'Password too short';
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 24),
                                  CupertinoButton.filled(
                                    onPressed: state.isSubmitting
                                        ? null
                                        : () async {
                                            final bloc = context
                                                .read<RegisterBloc>();
                                            bloc.add(
                                              RegisterSubmitted(context),
                                            );
                                          },
                                    child: state.isSubmitting
                                        ? const CupertinoActivityIndicator()
                                        : Text(
                                            AppLocalizations.of(
                                                  context,
                                                )?.register ??
                                                'Register',
                                          ),
                                  ),
                                  if (state.isSuccess)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.sucessRegister ??
                                            'Registration successful!',
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
                                        AppLocalizations.of(
                                              context,
                                            )?.faildRegister ??
                                            'Registration failed. Please try again.',
                                        style: TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontFamily: 'SFProDisplay',
                                        ),
                                        textAlign: TextAlign.center,
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
                backgroundColor: materialTheme.colorScheme.background,
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: BlocBuilder<RegisterBloc, RegisterState>(
                        builder: (context, state) {
                          final bloc = context.read<RegisterBloc>();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedPhoto(
                                imageAsset: AppAssets.logoApp,
                                height: 100,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                AppLocalizations.of(context)?.register ??
                                    'Register',
                                style: materialTheme.textTheme.headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              AnimatedTextFormField(
                                controller: bloc.firstNameController,
                                labelText: 'First Name',
                                icon: Icons.person_outline,
                                hintText: 'Enter your first name',
                                obscureText: false,
                                onChanged: (value) =>
                                    bloc.add(RegisterFirstNameChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'First name required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AnimatedTextFormField(
                                controller: bloc.lastNameController,
                                labelText: 'Last Name',
                                icon: Icons.person_outline,
                                hintText: 'Enter your last name',
                                obscureText: false,
                                onChanged: (value) =>
                                    bloc.add(RegisterLastNameChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Last name required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              AnimatedTextFormField(
                                controller: bloc.emailController,
                                labelText:
                                    AppLocalizations.of(context)?.email ??
                                    'Email',
                                icon: Icons.email_outlined,
                                hintText:
                                    AppLocalizations.of(context)?.email ??
                                    'Enter your email',
                                obscureText: false,
                                onChanged: (value) =>
                                    bloc.add(RegisterEmailChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email required';
                                  }
                                  if (!state.isEmailValid) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: SearchableCountryCodeDropdown(
                                      selectedCode: state.countryCode,
                                      selectedDialCode: state.dialCode,
                                      onChanged: (country) {
                                        bloc.add(
                                          RegisterCountryCodeChanged(
                                            country.code,
                                            country.dialCode,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AnimatedTextFormField(
                                      controller: bloc.phoneController,
                                      labelText: 'Phone',
                                      icon: Icons.phone,
                                      hintText:
                                          'Enter your phone or search country',
                                      obscureText: false,
                                      onChanged: (value) =>
                                          bloc.add(RegisterPhoneChanged(value)),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Phone required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AnimatedTextFormField(
                                controller: bloc.passwordController,
                                labelText:
                                    AppLocalizations.of(context)?.password ??
                                    'Password',
                                icon: Icons.lock_outline,
                                isPasswordField: true,
                                passwordVisible: state.showPassword,
                                onTogglePasswordVisibility: () => bloc.add(
                                  ToggleRegisterPasswordVisibility(),
                                ),
                                hintText:
                                    AppLocalizations.of(context)?.password ??
                                    'Enter your password',
                                onChanged: (value) =>
                                    bloc.add(RegisterPasswordChanged(value)),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password required';
                                  }
                                  if (!state.isPasswordValid) {
                                    return 'Password too short';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),
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
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () async {
                                          final bloc = context
                                              .read<RegisterBloc>();
                                          bloc.add(RegisterSubmitted(context));
                                        },
                                  child: state.isSubmitting
                                      ? const CircularProgressIndicator.adaptive()
                                      : Text(
                                          AppLocalizations.of(
                                                context,
                                              )?.register ??
                                              'Register',
                                        ),
                                ),
                              ),
                              if (state.isSuccess)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    'Registration successful!',
                                    style: TextStyle(
                                      color: materialTheme.colorScheme.primary,
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
                                      color: materialTheme.colorScheme.error,
                                    ),
                                    textAlign: TextAlign.center,
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
    );
  }
}
