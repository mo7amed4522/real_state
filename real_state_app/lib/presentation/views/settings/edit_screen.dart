// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/presentation/bloc/settings_bloc/edit_profile_bloc.dart';
import 'package:real_state_app/presentation/widgets/animated_text_form_field.dart';
import 'package:real_state_app/presentation/widgets/searchable_country_code_dropdown.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return BlocProvider(
      create: (_) => EditProfileBloc()..add(LoadEditProfile()),
      child: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator());
          }
          final avatar = state.avatarFileName != null
              ? Image.file(
                  File(state.avatarFileName!),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    AppAssets.profile,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  AppAssets.profile,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                );
          final theme = Theme.of(context);
          final cupertinoTheme = CupertinoTheme.of(context);
          final textStyle = isIOS
              ? cupertinoTheme.textTheme.textStyle
              : theme.textTheme.bodyLarge;
          // Removed unused labelStyle
          final nonEditableStyle = textStyle?.copyWith(color: Colors.grey);

          final form = ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(child: avatar),
                    ),
                    const SizedBox(height: 12),
                    // Edit mode toggle button
                    isIOS
                        ? CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            onPressed: () => context
                                .read<EditProfileBloc>()
                                .add(EditProfileEditModeToggled()),
                            child: Text(
                              state.isActive ? 'Disable Edit' : 'Enable Edit',
                            ),
                          )
                        : TextButton(
                            onPressed: () => context
                                .read<EditProfileBloc>()
                                .add(EditProfileEditModeToggled()),
                            child: Text(
                              state.isActive ? 'Disable Edit' : 'Enable Edit',
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextFormField(
                labelText: 'First Name',
                controller: TextEditingController(text: state.firstName),
                icon: isIOS ? CupertinoIcons.person : Icons.person_outline,
                enabled: state.isActive,
                onChanged: (v) => context.read<EditProfileBloc>().add(
                  EditProfileFirstNameChanged(v),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextFormField(
                labelText: 'Last Name',
                controller: TextEditingController(text: state.lastName),
                icon: isIOS ? CupertinoIcons.person : Icons.person_outline,
                enabled: state.isActive,
                onChanged: (v) => context.read<EditProfileBloc>().add(
                  EditProfileLastNameChanged(v),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextFormField(
                labelText: 'Email',
                controller: TextEditingController(text: state.email),
                icon: isIOS ? CupertinoIcons.mail : Icons.email_outlined,
                enabled: state.isActive,
                onChanged: (v) => context.read<EditProfileBloc>().add(
                  EditProfileEmailChanged(v),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedTextFormField(
                labelText: 'Password',
                controller: TextEditingController(text: state.password),
                icon: isIOS ? CupertinoIcons.lock : Icons.lock_outline,
                obscureText: true,
                enabled: state.isActive,
                onChanged: (v) => context.read<EditProfileBloc>().add(
                  EditProfilePasswordChanged(v),
                ),
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
                        context.read<EditProfileBloc>().add(
                          EditProfileCountryCodeChanged(
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
                      labelText: 'Phone',
                      controller: TextEditingController(text: state.phone),
                      icon: isIOS ? CupertinoIcons.phone : Icons.phone,
                      enabled: state.isActive,
                      onChanged: (v) => context.read<EditProfileBloc>().add(
                        EditProfilePhoneChanged(v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Role: ${state.role}', style: nonEditableStyle),
              const SizedBox(height: 8),
              Text('Status: ${state.status}', style: nonEditableStyle),
              const SizedBox(height: 8),
              Text('Created At: ${state.createdAt}', style: nonEditableStyle),
              const SizedBox(height: 8),
              Text('Updated At: ${state.updatedAt}', style: nonEditableStyle),
              const SizedBox(height: 24),
              isIOS
                  ? CupertinoButton.filled(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<EditProfileBloc>().add(
                              EditProfileSubmitted(),
                            ),
                      child: state.isSubmitting
                          ? const CupertinoActivityIndicator()
                          : const Text('Update'),
                    )
                  : ElevatedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<EditProfileBloc>().add(
                              EditProfileSubmitted(),
                            ),
                      child: state.isSubmitting
                          ? const CircularProgressIndicator.adaptive()
                          : const Text('Update'),
                    ),
              if (state.isSuccess)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Profile updated!',
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (state.isFailure)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Update failed. Please try again.',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );

          if (isIOS) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: const Text('Edit Profile'),
                leading: Directionality.of(context) == TextDirection.ltr
                    ? CupertinoNavigationBarBackButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      )
                    : null,
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () => context.read<EditProfileBloc>().add(
                    EditProfileEditModeToggled(),
                  ),
                  child: Text(state.isActive ? 'Done' : 'Edit'),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: SafeArea(child: form),
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: SafeArea(child: form),
            );
          }
        },
      ),
    );
  }
}
