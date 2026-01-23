import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Exercise Info Page
/// Information screen about eye exercises before profile selection
class ExerciseInfoPage extends StatefulWidget {
  const ExerciseInfoPage({super.key});

  @override
  State<ExerciseInfoPage> createState() => _ExerciseInfoPageState();
}

class _ExerciseInfoPageState extends State<ExerciseInfoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollIndicatorController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollIndicator = true;

  @override
  void initState() {
    super.initState();
    _scrollIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      // Hide indicator when scrolled down
      if (currentScroll > 50) {
        if (_showScrollIndicator) {
          setState(() => _showScrollIndicator = false);
        }
      } else {
        if (!_showScrollIndicator) {
          setState(() => _showScrollIndicator = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollIndicatorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.medicalBlue,
                      AppColors.medicalTeal,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.medicalBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.activity,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                l10n.exerciseTitle,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Benefits
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      _buildBenefitItem(
                        icon: LucideIcons.eye,
                        title: l10n.exerciseBenefit1Title,
                        description: l10n.exerciseBenefit1Desc,
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.focus,
                        title: l10n.exerciseBenefit2Title,
                        description: l10n.exerciseBenefit2Desc,
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.zap,
                        title: l10n.exerciseBenefit3Title,
                        description: l10n.exerciseBenefit3Desc,
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.heart,
                        title: l10n.exerciseBenefit4Title,
                        description: l10n.exerciseBenefit4Desc,
                      ),
                      const SizedBox(height: 20),
                      _buildBenefitItem(
                        icon: LucideIcons.moon,
                        title: l10n.exerciseBenefit5Title,
                        description: l10n.exerciseBenefit5Desc,
                      ),
                        ],
                      ),
                    ),
                    // Scroll Indicator (fade at bottom)
                    if (_showScrollIndicator)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FadeTransition(
                                  opacity: _scrollIndicatorController,
                                  child: Column(
                                    children: [
                                      const Icon(
                                        LucideIcons.chevronDown,
                                        size: 24,
                                        color: AppColors.medicalBlue,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.exerciseScrollDown,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.medicalBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Start Button
              AppButton(
                text: l10n.exerciseStartExercises,
                icon: LucideIcons.arrowRight,
                onPressed: () => context.push(AppRoutes.exerciseProfile),
                backgroundColor: AppColors.medicalBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.medicalBluePale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.medicalBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
