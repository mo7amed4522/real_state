// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

// Riverpod provider for selected index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavBarWidget extends ConsumerWidget {
  const CustomBottomNavBarWidget({super.key});

  static const _androidIcons = [
    Icons.home_rounded,
    Icons.list_alt_rounded,
    Icons.chat_bubble_rounded,
    Icons.settings_rounded,
  ];

  static const _iosIcons = [
    CupertinoIcons.home,
    CupertinoIcons.square_list,
    CupertinoIcons.chat_bubble_2,
    CupertinoIcons.settings,
  ];

  static const _labels = ['HOME', 'ITEMS', 'CHAT', 'SETTING'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final isIOS = Platform.isIOS;
    final icons = isIOS ? _iosIcons : _androidIcons;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget navBar = Material(
      color: colorScheme.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: LayoutGrid(
          columnSizes: [1.fr, 1.fr, 1.fr, 1.fr],
          rowSizes: [auto],
          children: List.generate(4, (index) {
            final selected = index == selectedIndex;
            return GestureDetector(
              onTap: () =>
                  ref.read(bottomNavIndexProvider.notifier).state = index,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticInOut,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.customAccent.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      color: selected
                          ? AppTheme.lightTheme.primaryColor
                          : colorScheme.onSurface.withOpacity(0.6),
                      size: selected ? 30 : 25,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? AppTheme.lightTheme.primaryColor
                            : colorScheme.onSurface.withOpacity(0.6),
                        fontSize: selected ? 14 : 12,
                        fontFamily: isIOS ? 'SF Pro' : 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
    Widget floatingNavBar = Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 24),
      child: navBar,
    );
    if (isIOS) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CupertinoUserInterfaceLevel(
          data: CupertinoUserInterfaceLevelData.elevated,
          child: floatingNavBar,
        ),
      );
    } else {
      return floatingNavBar;
    }
  }
}
