import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goz_testi/core/theme/app_theme.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/services/notification_service.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/core/services/ad_service.dart';
import 'package:goz_testi/core/services/purchase_service.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  runApp(const ProviderScope(child: GozTestiApp()));
}

void _initializeServicesInBackground() {
  // AdMob
  AdService().initialize().catchError((e) {
    debugPrint('AdMob init error: $e');
  });
  
  // Notification
  NotificationService().initialize().catchError((e) {
    debugPrint('Notification init error: $e');
  });
  
  // Purchase
  PurchaseService().initialize().catchError((e) {
    debugPrint('Purchase init error: $e');
  });
  
  // Storage
  StorageService().resetDailyCountsIfNeeded().catchError((e) {
    debugPrint('Storage init error: $e');
  });
  
  // Reset premium for testing
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('is_premium', false);
  }).catchError((e) {
    debugPrint('Prefs error: $e');
  });
}

/// Main Application Widget
class GozTestiApp extends ConsumerWidget {
  const GozTestiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Göz Testi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
