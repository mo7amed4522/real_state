// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:real_state_app/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter error: ${details.exceptionAsString()}');
  };
  await Hive.initFlutter();
  await _handleLocationPermission();
  await dotenv.load(fileName: ".env");
  // --- TEST CODE TO TRIGGER LOCAL NETWORK PERMISSION PROMPT ---
  try {
    // Attempt to connect to localhost; this will fail but will trigger the permission prompt
    await Socket.connect('127.0.0.1', 80).timeout(Duration(seconds: 1));
  } catch (_) {}
  // --- END TEST CODE ---
  try {
    await Hive.initFlutter();
    await _handleLocationPermission();
    await dotenv.load(fileName: ".env");
    runApp(ProviderScope(child: RealStateApp()));
  } catch (e, stack) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization error: $e'))),
      ),
    );
    debugPrint('Error during initialization: $e\\n$stack');
  }
}

Future<void> _handleLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  // If deniedForever, you may want to show a dialog in your first screen instead.
}

class RealStateApp extends StatelessWidget {
  const RealStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformApp.router(
      title: AppLocalizations.of(context)?.appTitle ?? 'Real Estate App',
      material: (_, __) => MaterialAppRouterData(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      ),
      cupertino: (_, __) => CupertinoAppRouterData(
        theme: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const CupertinoThemeData(brightness: Brightness.dark)
            : const CupertinoThemeData(brightness: Brightness.light),
        debugShowCheckedModeBanner: false,
      ),
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        if (child == null) {
          return Scaffold(
            body: Center(
              child: Text('Router returned null (no screen to display)'),
            ),
          );
        }
        return child;
      },
    );
  }
}
