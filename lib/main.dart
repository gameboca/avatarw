import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'providers/creator_provider.dart';
import 'providers/houses_provider.dart';
import 'providers/mods_provider.dart';
import 'providers/workbench_provider.dart';
import 'services/revenue_cat_service.dart';
import 'services/storage_service.dart';
import 'ui/screens/main_shell_screen.dart';
import 'ui/screens/paywall_onboarding_screen.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark navigation & status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage & RevenueCat
  await StorageService.instance.init();
  await RevenueCatService.instance.init();

  runApp(const ModsAvatarApp());
}

class ModsAvatarApp extends StatelessWidget {
  const ModsAvatarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = Uri.base.queryParameters['screen'] ?? '';
    Widget destination;
    switch (screen) {
      case 'paywall':
        destination = const PaywallOnboardingScreen();
        break;
      case 'mods':
        destination = const MainShellScreen(initialTab: 0);
        break;
      case 'interior':
        destination = const MainShellScreen(initialTab: 1);
        break;
      case 'workbench':
        destination = const MainShellScreen(initialTab: 2);
        break;
      case 'creator':
        destination = const MainShellScreen(initialTab: 3);
        break;
      default:
        destination = const SplashScreen();
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModsProvider()),
        ChangeNotifierProvider(create: (_) => HousesProvider()),
        ChangeNotifierProvider(create: (_) => CreatorProvider()),
        ChangeNotifierProvider(create: (_) => WorkbenchProvider()),
        ChangeNotifierProvider.value(value: RevenueCatService.instance),
      ],
      child: MaterialApp(
        title: 'Mods For Avatar World',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.cyanAccent,
            surface: AppColors.surface,
          ),
          textTheme: GoogleFonts.montserratTextTheme(
            ThemeData.dark().textTheme,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        home: destination,
      ),
    );
  }
}
