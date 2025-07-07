// --- SettingScreen Widget ---

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/assets/app_assets.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';
import 'package:real_state_app/presentation/bloc/screens/setting_bloc.dart';
import 'package:real_state_app/presentation/widgets/loader.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfile()),
      child: _SettingContent(),
    );
  }
}

class _SettingContent extends StatelessWidget {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account? This will not remove your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await LocalStorage.clear();
              if (context.mounted) {
                context.go('/');
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state.loading) {
          return Center(child: Loader().lottieWidget());
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
        final name = '${state.firstName} ${state.lastName}';

        final cards = [
          _SettingCard(
            icon: isIOS ? CupertinoIcons.settings : Icons.edit,
            label: 'Edit Profile',
            onTap: () => context.go('/edit-screen'),
          ),
          _SettingCard(
            icon: isIOS ? CupertinoIcons.lock : Icons.privacy_tip,
            label: 'Privacy & Policy',
            onTap: () => context.go('/privcy-screen'),
          ),
          _SettingCard(
            icon: isIOS
                ? CupertinoIcons.creditcard
                : Icons.account_balance_wallet,
            label: 'My Wallet',
            onTap: () => context.go('/wallet-screen'),
          ),
          _SettingCard(
            icon: isIOS ? CupertinoIcons.square_arrow_right : Icons.logout,
            label: 'Log Out',
            onTap: () => _showLogoutDialog(context),
          ),
          _SettingCard(
            icon: isIOS ? CupertinoIcons.delete : Icons.delete_forever,
            label: 'Remove Account',
            onTap: () {},
            color: Colors.red,
          ),
        ];

        final content = ListView(
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
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontFamily: "SFProDisplay",
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            ...cards,
          ],
        );

        if (isIOS) {
          return CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text(
                'Settings',
                style: TextStyle(fontFamily: "SFProDisplay", fontSize: 17),
              ),
            ),
            child: SafeArea(child: content),
          );
        } else {
          return SafeArea(child: content);
        }
      },
    );
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final card = ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        label,
        style: TextStyle(color: color, fontFamily: "SFProDisplay"),
      ),
      trailing: isIOS
          ? const Icon(CupertinoIcons.right_chevron)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: isIOS
          ? Material(color: Colors.transparent, child: card)
          : Card(child: card),
    );
  }
}
