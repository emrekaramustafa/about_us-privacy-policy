import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/disclaimer/presentation/pages/disclaimer_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/tests/visual_acuity/presentation/pages/visual_acuity_page.dart';
import '../../features/tests/color_vision/presentation/pages/color_vision_page.dart';
import '../../features/tests/astigmatism/presentation/pages/astigmatism_page.dart';
import '../../features/tests/binocular_vision/presentation/pages/binocular_vision_page.dart';
import '../../features/tests/near_vision/presentation/pages/near_vision_page.dart';
import '../../features/tests/macular/presentation/pages/macular_page.dart';
import '../../features/tests/peripheral_vision/presentation/pages/peripheral_vision_page.dart';
import '../../features/tests/eye_movement/presentation/pages/eye_movement_page.dart';
import '../../features/facts/presentation/pages/facts_page.dart';
import '../../features/result/presentation/pages/result_page.dart';
import '../../features/result/presentation/pages/detailed_analysis_page.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import '../../features/paywall/presentation/pages/soft_gate_page.dart';
import '../../features/eye_exercises/presentation/pages/exercise_info_page.dart';
import '../../features/eye_exercises/presentation/pages/profile_selection_page.dart';
import '../../features/eye_exercises/presentation/pages/exercise_list_page.dart';
import '../../features/eye_exercises/presentation/pages/exercise_detail_page.dart';
import '../../features/eye_exercises/presentation/pages/exercise_completion_page.dart';
import '../../features/eye_exercises/domain/models/exercise_model.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/privacy_policy_page.dart';
import '../../features/settings/presentation/pages/terms_of_service_page.dart';
import '../../features/history/presentation/pages/test_history_page.dart';
import '../../features/home/presentation/pages/daily_test_info_page.dart';

/// Route path constants
class AppRoutes {
  static const String splash = '/';
  static const String disclaimer = '/disclaimer';
  static const String home = '/home';
  static const String visualAcuity = '/test/visual-acuity';
  static const String colorVision = '/test/color-vision';
  static const String astigmatism = '/test/astigmatism';
  static const String stereopsis = '/test/stereopsis';
  static const String nearVision = '/test/near-vision';
  static const String macular = '/test/macular';
  static const String peripheralVision = '/test/peripheral-vision';
  static const String diplopia = '/test/diplopia';
  static const String eyeMovement = '/test/eye-movement';
  static const String facts = '/facts';
  static const String result = '/result';
  static const String detailedAnalysis = '/detailed-analysis';
  static const String paywall = '/paywall';
  static const String softGate = '/soft-gate';
  static const String exerciseInfo = '/exercises/info';
  static const String exerciseProfile = '/exercises/profile';
  static const String exerciseList = '/exercises/list';
  static const String exerciseDetail = '/exercises/detail';
  static const String exerciseCompletion = '/exercises/completion';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
  static const String testHistory = '/history';
  static const String dailyTestInfo = '/daily-test-info';
}

/// App Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.disclaimer,
        builder: (context, state) => const DisclaimerPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.visualAcuity,
        builder: (context, state) => const VisualAcuityPage(),
      ),
      GoRoute(
        path: AppRoutes.colorVision,
        builder: (context, state) => const ColorVisionPage(),
      ),
      GoRoute(
        path: AppRoutes.astigmatism,
        builder: (context, state) => const AstigmatismPage(),
      ),
      GoRoute(
        path: AppRoutes.stereopsis,
        builder: (context, state) => const BinocularVisionPage(),
      ),
      GoRoute(
        path: AppRoutes.nearVision,
        builder: (context, state) => const NearVisionPage(),
      ),
      GoRoute(
        path: AppRoutes.macular,
        builder: (context, state) => const MacularPage(),
      ),
      GoRoute(
        path: AppRoutes.peripheralVision,
        builder: (context, state) => const PeripheralVisionPage(),
      ),
      GoRoute(
        path: AppRoutes.eyeMovement,
        builder: (context, state) => const EyeMovementPage(),
      ),
      GoRoute(
        path: AppRoutes.facts,
        builder: (context, state) => const FactsPage(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultPage(
            testType: extra?['testType'] ?? 'unknown',
            score: extra?['score'] ?? 0,
            totalQuestions: extra?['totalQuestions'] ?? 0,
            details: extra?['details'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.detailedAnalysis,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return DetailedAnalysisPage(
            testType: extra?['testType'] ?? 'unknown',
            score: extra?['score'] ?? 0,
            totalQuestions: extra?['totalQuestions'] ?? 0,
            details: extra?['details'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallPage(),
      ),
      GoRoute(
        path: AppRoutes.softGate,
        builder: (context, state) => const SoftGatePage(),
      ),
      GoRoute(
        path: AppRoutes.exerciseInfo,
        builder: (context, state) => const ExerciseInfoPage(),
      ),
      GoRoute(
        path: AppRoutes.exerciseProfile,
        builder: (context, state) => const ProfileSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.exerciseList,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ExerciseListPage(
            profile: extra?['profile'] ?? 'adult',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ExerciseDetailPage(
            exercise: extra?['exercise'] as ExerciseModel,
            profile: extra?['profile'] ?? 'adult',
            exerciseIndex: extra?['exerciseIndex'] ?? 0,
            totalExercises: extra?['totalExercises'] ?? 10,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseCompletion,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ExerciseCompletionPage(
            profile: extra?['profile'] ?? 'adult',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (context, state) => const TermsOfServicePage(),
      ),
      GoRoute(
        path: AppRoutes.testHistory,
        builder: (context, state) => const TestHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.dailyTestInfo,
        builder: (context, state) => const DailyTestInfoPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

