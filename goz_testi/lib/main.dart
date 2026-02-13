import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import 'package:goz_testi/core/theme/app_theme.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/providers/locale_provider.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yakalanmamış hataları yakala; uygulama sessizce kapanmasın
  runZonedGuarded(() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error: $error');
      debugPrint('$stack');
      return true; // hatayı işledik, uygulama kapanmasın
    };

    _init().then((_) {
      runApp(const ProviderScope(child: GozTestiApp()));
    }).catchError((e, st) {
      debugPrint('Init error: $e');
      debugPrint('$st');
      runApp(const ProviderScope(child: GozTestiApp()));
    });
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('$stack');
  });
}

Future<void> _init() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services in background (don't wait)
  _initializeServicesInBackground();
}

void _initializeServicesInBackground() {
  // AdMob
  AdService().initialize().catchError((e) {
    debugPrint('AdMob init error: $e');
  });

  // Bildirim servisi açılışta başlatılmıyor: kullanıcı bildirime "Hayır" dediyse
  // iOS'ta plugin başlatılırken çökme olabiliyor. Bildirimler ilk kullanımda lazy-initialize.

  // Purchase açılışta başlatılmıyor: bağlantı koptuktan sonra StoreKit stream aboneliği
  // iOS'ta çökme yapabildiği için satın alma ilk kullanımda (paywall/restore) lazy-initialize.

  // Storage
  StorageService().resetDailyCountsIfNeeded().catchError((e) {
    debugPrint('Storage init error: $e');
  });
}

/// Main Application Widget
class GozTestiApp extends ConsumerWidget {
  const GozTestiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
      title: 'Eye Test',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      
      // Use selected locale or fall back to system locale
      locale: locale,
      
      // Localization delegates
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SupportedLocales.all,
      
      // Locale resolution callback
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // If user has selected a locale, use it
        if (locale != null) {
          return locale;
        }
        
        // Try to match device locale
        if (deviceLocale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        
        // Default to English
        return SupportedLocales.english;
      },
    );
  }
}
