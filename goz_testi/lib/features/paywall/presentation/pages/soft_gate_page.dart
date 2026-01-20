import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/services/ad_service.dart';
import 'package:goz_testi/core/services/storage_service.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Soft Gate Page
/// 
/// Shown after 3 tests in a day for free users
/// Offers: Watch ad for +1 test, Go premium, or Later
class SoftGatePage extends ConsumerStatefulWidget {
  const SoftGatePage({super.key});

  @override
  ConsumerState<SoftGatePage> createState() => _SoftGatePageState();
}

class _SoftGatePageState extends ConsumerState<SoftGatePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AdService _adService = AdService();
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    
    // Preload ad
    _adService.loadRewardedAd();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _watchAd() async {
    // Check if user has remaining credits
    final remaining = await _storageService.getRemainingTestCredits();
    if (remaining <= 0) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dailyTestQuotaReached),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
      return;
    }

    if (!_adService.isRewardedAdReady) {
      // Try to load ad
      await _adService.loadRewardedAd();
      if (!_adService.isRewardedAdReady) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adLoadFailed),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    final success = await _adService.showRewardedAd(
      context: context,
      onRewarded: () async {
        // Grant +1 test credit
        await _storageService.addExtraTestCredit();
        
        // Refresh daily count and remaining credits
        ref.invalidate(dailyTestCountProvider);
        ref.invalidate(remainingTestCreditsProvider);
        
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adRewardEarned),
              backgroundColor: AppColors.successGreen,
            ),
          );
          context.pop();
        }
      },
      onAdDismissed: () {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );

    if (!success && mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _goPremium() {
    context.push(AppRoutes.paywall);
  }

  void _later() {
    // Go to home page instead of just popping
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              FadeTransition(
                opacity: _controller,
                child: ScaleTransition(
                  scale: _controller,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.medicalBlue,
                          AppColors.medicalTeal,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.eye,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              FadeTransition(
                opacity: _controller,
                child: Text(
                  AppLocalizations.of(context)!.dailyTestLimit,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              FadeTransition(
                opacity: _controller,
                child: Text(
                  AppLocalizations.of(context)!.dailyTestLimitDesc,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Options
              FadeTransition(
                opacity: _controller,
                child: Column(
                  children: [
                    // Watch Ad Option
                    _buildOptionCard(
                      icon: LucideIcons.play,
                      title: AppLocalizations.of(context)!.watchAd,
                      subtitle: AppLocalizations.of(context)!.earnTestCredit,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.medicalBlue,
                          AppColors.medicalTeal,
                        ],
                      ),
                      onTap: _isLoading ? null : _watchAd,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Premium Option
                    Consumer(
                      builder: (context, ref, child) {
                        final productAsync = ref.watch(premiumProductProvider);
                        
                        return _buildOptionCard(
                          icon: LucideIcons.crown,
                          title: AppLocalizations.of(context)!.goPremium,
                          subtitle: productAsync.when(
                            data: (product) {
                              final price = product?.price ?? '';
                              if (price.isNotEmpty) {
                                return '${AppLocalizations.of(context)!.premiumLifetimePrice(price)} - ${AppLocalizations.of(context)!.unlimitedTestsAndAnalysis}';
                              }
                              return AppLocalizations.of(context)!.unlimitedTestsAndAnalysis;
                            },
                            loading: () => AppLocalizations.of(context)!.unlimitedTestsAndAnalysis,
                            error: (_, __) => AppLocalizations.of(context)!.unlimitedTestsAndAnalysis,
                          ),
                          gradient: AppColors.premiumGradient,
                          onTap: _goPremium,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Later Option
                    _buildOptionCard(
                      icon: LucideIcons.clock,
                      title: AppLocalizations.of(context)!.later,
                      subtitle: AppLocalizations.of(context)!.backToHome,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.borderLight,
                          AppColors.borderLight,
                        ],
                      ),
                      onTap: _later,
                      isSecondary: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback? onTap,
    bool isLoading = false,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSecondary ? null : gradient,
          color: isSecondary ? AppColors.borderLight : null,
          borderRadius: BorderRadius.circular(16),
          border: isSecondary
              ? Border.all(color: AppColors.borderLight, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: (isSecondary ? AppColors.borderLight : AppColors.medicalBlue)
                  .withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSecondary
                    ? Colors.white
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      icon,
                      color: isSecondary
                          ? AppColors.textSecondary
                          : Colors.white,
                      size: 24,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSecondary
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isSecondary
                          ? AppColors.textSecondary
                          : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                LucideIcons.chevronRight,
                color: isSecondary
                    ? AppColors.textSecondary
                    : Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
