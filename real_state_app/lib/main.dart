import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:real_state_app/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await _handleLocationPermission();
  await dotenv.load(fileName: ".env");
  runApp(const RealStateApp());
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
    );
  }
}
