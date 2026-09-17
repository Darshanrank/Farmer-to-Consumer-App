import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget.
///
/// Wraps the app in [ProviderScope] for Riverpod state management
/// and configures Material 3 theming, routing, and localization.
class AgroMarketApp extends ConsumerWidget {
  const AgroMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'AgroMarket',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Default to light; can be user-controlled later

      // Routing
      routerConfig: ref.watch(appRouterProvider),

      // Localization
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('gu'),
      ],
      locale: const Locale('en'), // Default; can be user-controlled later
    );
  }
}
