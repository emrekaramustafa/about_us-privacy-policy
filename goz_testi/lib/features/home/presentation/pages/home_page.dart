import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import '../widgets/test_card.dart';

/// Home Page
/// 
/// Displays all available eye tests in a modern grid layout.
/// Tests are marked as free or premium based on availability.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  List<TestCategory> _getTests(AppLocalizations l10n) {
    return [
      TestCategory(
        id: 'visual_acuity',
        title: l10n.visualAcuityTitle,
        description: l10n.visualAcuityDesc,
        icon: LucideIcons.eye,
        route: AppRoutes.visualAcuity,
        isPremium: false,
        color: AppColors.medicalBlue,
      ),
      TestCategory(
        id: 'color_vision',
        title: l10n.colorVisionTitle,
        description: l10n.colorVisionDesc,
        icon: LucideIcons.palette,
        route: AppRoutes.colorVision,
        isPremium: false,
        color: AppColors.medicalTeal,
      ),
      TestCategory(
        id: 'astigmatism',
        title: l10n.astigmatismTitle,
        description: l10n.astigmatismDesc,
        icon: LucideIcons.focus,
        route: AppRoutes.astigmatism,
        isPremium: false,
        color: AppColors.premiumGold,
      ),
      TestCategory(
        id: 'stereopsis',
        title: l10n.stereopsisTitle,
        description: l10n.stereopsisDesc,
        icon: LucideIcons.eye,
        route: AppRoutes.stereopsis,
        isPremium: false,
        color: AppColors.medicalTeal,
      ),
      TestCategory(
        id: 'near_vision',
        title: l10n.nearVisionTitle,
        description: l10n.nearVisionDesc,
        icon: LucideIcons.bookOpen,
        route: AppRoutes.nearVision,
        isPremium: false,
        color: AppColors.medicalTeal,
      ),
      TestCategory(
        id: 'macular',
        title: l10n.macularTitle,
        description: l10n.macularDesc,
        icon: LucideIcons.grid,
        route: AppRoutes.macular,
        isPremium: false,
        color: AppColors.medicalTeal,
      ),
      TestCategory(
        id: 'peripheral_vision',
        title: l10n.peripheralVisionTitle,
        description: l10n.peripheralVisionDesc,
        icon: LucideIcons.scan,
        route: AppRoutes.peripheralVision,
        isPremium: false,
        color: AppColors.medicalBlue,
      ),
      TestCategory(
        id: 'eye_movement',
        title: l10n.eyeMovementTitle,
        description: l10n.eyeMovementDesc,
        icon: LucideIcons.move,
        route: AppRoutes.eyeMovement,
        isPremium: false,
        color: AppColors.premiumGold,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTestTap(TestCategory test, AppLocalizations l10n) {
    if (test.isComingSoon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${test.title} ${l10n.comingSoon}!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (test.route != null) {
      context.push(test.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tests = _getTests(l10n);
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isSmallScreen = screenWidth < 400;
                  final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
                  final titleFontSize = isSmallScreen ? 26.0 : 32.0;
                  
                  return Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding, isSmallScreen ? 16 : 20, horizontalPadding, 8),
                    child: FadeTransition(
                      opacity: _controller,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.homeTitle,
                                        style: GoogleFonts.inter(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.homeSubtitle,
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Daily test limit info for free users
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final isPremium = ref.watch(isPremiumProvider);
                                          final remainingAsync = ref.watch(remainingTestCreditsProvider);
                                          
                                          if (isPremium) return const SizedBox.shrink();
                                          
                                          return remainingAsync.when(
                                            data: (remaining) {
                                              final hasNoCredits = remaining <= 0;
                                              return InkWell(
                                                onTap: () {
                                                  context.push(AppRoutes.dailyTestInfo);
                                                },
                                                borderRadius: BorderRadius.circular(8),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: hasNoCredits
                                                        ? AppColors.warningYellow.withOpacity(0.1)
                                                        : AppColors.medicalTeal.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: hasNoCredits
                                                        ? Border.all(
                                                            color: AppColors.warningYellow.withOpacity(0.3),
                                                          )
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        hasNoCredits
                                                            ? LucideIcons.info
                                                            : LucideIcons.checkCircle2,
                                                        size: 14,
                                                        color: hasNoCredits
                                                            ? AppColors.warningYellow
                                                            : AppColors.medicalTeal,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Flexible(
                                                        child: Text(
                                                          l10n.watchAdForTest(remaining),
                                                          style: GoogleFonts.inter(
                                                            fontSize: 12,
                                                            fontWeight: hasNoCredits
                                                                ? FontWeight.w600
                                                                : FontWeight.w500,
                                                            color: hasNoCredits
                                                                ? AppColors.warningYellow
                                                                : AppColors.medicalTeal,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        LucideIcons.chevronRight,
                                                        size: 12,
                                                        color: hasNoCredits
                                                            ? AppColors.warningYellow
                                                            : AppColors.medicalTeal,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            loading: () => const SizedBox.shrink(),
                                            error: (_, __) => const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                // Action Buttons
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.borderLight),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(LucideIcons.settings, size: 22),
                                    color: AppColors.textSecondary,
                                    onPressed: () => context.push(AppRoutes.settings),
                                    tooltip: l10n.settings,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Eye Exercises Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.15, 1.0),
                  ),
                  child: _buildEyeExercisesBanner(l10n),
                ),
              ),
            ),

            // Eye Tests Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.2, 1.0),
                  ),
                  child: _buildEyeTestsBanner(l10n, tests),
                ),
              ),
            ),

            // Premium Banner (only show if not premium)
            Consumer(
              builder: (context, ref, child) {
                final isPremium = ref.watch(isPremiumProvider);
                if (isPremium) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.25, 1.0),
                      ),
                      child: _buildPremiumBanner(l10n),
                    ),
                  ),
                );
              },
            ),

            // Facts Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.3, 1.0),
                  ),
                  child: _buildFactsBanner(l10n),
                ),
              ),
            ),

            // History Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.35, 1.0),
                  ),
                  child: _buildHistoryBanner(l10n),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildEyeExercisesBanner(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.exerciseInfo),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.medicalBlue,
              AppColors.medicalTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.activity,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.eyeExercises,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.eyeExercisesDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.paywall),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.premiumGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.premiumGold.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.crown,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.goPremium,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.goPremiumDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactsBanner(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.facts),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.tealGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.lightbulb,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.didYouKnow,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.didYouKnowDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEyeTestsBanner(AppLocalizations l10n, List<TestCategory> tests) {
    return GestureDetector(
      onTap: () => _showTestsDialog(l10n, tests),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.medicalBlue,
              AppColors.medicalTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.eye,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.eyeTests,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.eyeTestsDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showTestsDialog(AppLocalizations l10n, List<TestCategory> tests) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.cleanWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                l10n.eyeTests,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Tests Grid
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  return TestCard(
                    test: tests[index],
                    onTap: () {
                      Navigator.of(context).pop();
                      _onTestTap(tests[index], l10n);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBanner(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.testHistory),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.medicalTeal,
              AppColors.medicalBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.medicalTeal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.history,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.testHistory,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.testHistoryDesc,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Test category data model
class TestCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String? route;
  final bool isPremium;
  final Color color;
  final bool isComingSoon;

  const TestCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.isPremium,
    required this.color,
    this.isComingSoon = false,
  });
}
