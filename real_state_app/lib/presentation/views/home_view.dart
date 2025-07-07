// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_state_app/core/constant/constatnt.dart';
import 'package:real_state_app/presentation/views/screens/chat_screen.dart';
import 'package:real_state_app/presentation/views/screens/home_screen.dart';
import 'package:real_state_app/presentation/views/screens/itemes_screen.dart';
import 'package:real_state_app/presentation/views/screens/setting.dart';
import 'package:real_state_app/presentation/widgets/custom_bottom_nav_bar.dart';

// Example screens and titles
final List<Widget> screens = [
  const HomeScreen(),
  const ItemesScreen(),
  ChatScreen(
    currentUserId: userData['id'] ?? 'd779b4f2-92aa-46ea-a3b2-17628aa0071a',
    currentUserName: userData['firstName'] ?? 'John Doe',
  ),
  const SettingScreen(),
];

final titles = ['Home', 'Items', 'Chat', 'Settings'];

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final isIOS = Platform.isIOS;
    Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: isIOS
          ? CupertinoPageScaffold(child: _buildBody(context, selectedIndex))
          : Scaffold(body: _buildBody(context, selectedIndex)),
    );
  }

  Widget _buildBody(BuildContext context, int selectedIndex) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: screens[selectedIndex],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: const IgnorePointer(
            ignoring: false,
            child: CustomBottomNavBarWidget(),
          ),
        ),
      ],
    );
  }
}
