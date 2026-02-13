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

/// Daily Test Info Page
/// 
/// Shows information about daily test limits and allows users to watch ads
/// for additional test credits (unlimited)
class DailyTestInfoPage extends ConsumerStatefulWidget {
  const DailyTestInfoPage({super.key});

  @override
  ConsumerState<DailyTestInfoPage> createState() => _DailyTestInfoPageState();
}

class _DailyTestInfoPageState extends ConsumerState<DailyTestInfoPage>
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
    // Check if user can watch ad for extra credit
    final canWatch = await _storageService.canWatchAdForExtraCredit();
    if (!canWatch) {
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

    setState(() => _isLoading = true);

    // Try to load ad if not ready
    if (!_adService.isRewardedAdReady) {
      bool adLoaded = false;
      await _adService.loadRewardedAd(
        onAdLoaded: () {
          adLoaded = true;
        },
        onAdFailedToLoad: () {
          adLoaded = false;
        },
      );
      
      // Wait a bit for ad to load
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (!adLoaded && !_adService.isRewardedAdReady) {
        if (mounted) {
          setState(() => _isLoading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adLoadFailed),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    final success = await _adService.showRewardedAd(
      context: context,
      onRewarded: () async {
        // Grant +1 test credit
        await _storageService.addExtraTestCredit();
        
        // Refresh daily count and remaining credits
        ref.invalidate(dailyTestCountProvider);
        ref.invalidate(remainingTestCreditsProvider);
        ref.invalidate(canWatchAdForExtraCreditProvider);
        
        if (mounted) {
          setState(() => _isLoading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.adRewardEarned),
              backgroundColor: AppColors.successGreen,
              duration: const Duration(seconds: 2),
            ),
          );
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adFailed),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  void _continue() {
    context.pop();
  }

  Widget _buildPremiumAdvantage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            LucideIcons.x,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.dailyTestInfo,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.medicalBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.testTube,
                    size: 40,
                    color: AppColors.medicalBlue,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Consumer(
                  builder: (context, ref, child) {
                    final remainingAsync = ref.watch(remainingTestCreditsProvider);
                    
                    return remainingAsync.when(
                      data: (remaining) {
                        return Text(
                          l10n.adFreeTestsToday(remaining),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                      loading: () => Text(
                        l10n.adFreeTestsToday(3),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      error: (_, __) => Text(
                        l10n.adFreeTestsToday(3),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Description (Clickable)
                Consumer(
                  builder: (context, ref, child) {
                    final remainingAsync = ref.watch(remainingTestCreditsProvider);
                    final canWatchAsync = ref.watch(canWatchAdForExtraCreditProvider);
                    
                    return remainingAsync.when(
                      data: (remaining) {
                        return canWatchAsync.when(
                          data: (canWatchAd) {
                            return InkWell(
                              onTap: canWatchAd ? _watchAd : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.medicalBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.medicalBlue.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            l10n.watchAdForExtraTest,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.medicalBlue,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          LucideIcons.playCircle,
                                          size: 20,
                                          color: AppColors.medicalBlue,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      canWatchAd 
                                        ? l10n.testCreditsRemaining(remaining)
                                        : l10n.dailyTestQuotaReached,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: canWatchAd 
                                          ? AppColors.medicalBlue.withOpacity(0.8)
                                          : AppColors.errorRed,
                                      ),
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
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.medicalTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.medicalTeal.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.info,
                            size: 20,
                            color: AppColors.medicalTeal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.about,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.medicalTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.dailyTestLimitDesc,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Watch Ad Button
                AppButton(
                  text: _isLoading ? l10n.adLoading : l10n.watchAdForExtraTest,
                  icon: _isLoading ? null : LucideIcons.playCircle,
                  onPressed: _isLoading ? null : _watchAd,
                  width: double.infinity,
                  backgroundColor: AppColors.medicalBlue,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                
                // Continue Button
                AppButton(
                  text: l10n.continueFree,
                  icon: LucideIcons.arrowRight,
                  onPressed: _continue,
                  width: double.infinity,
                  backgroundColor: AppColors.medicalTeal,
                  isOutlined: true,
                ),
                const SizedBox(height: 24),
                
                // Premium CTA
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.premiumGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final productAsync = ref.watch(premiumProductProvider);
                      
                      return TextButton(
                        onPressed: () {
                          context.pop();
                          context.push(AppRoutes.paywall);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: productAsync.when(
                          data: (product) {
                            // Price comes from App Store/Play Store with correct currency
                            final price = product?.price ?? '';
                            if (price.isNotEmpty) {
                              return Text(
                                l10n.premiumLifetimePrice(price),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            }
                            return Text(
                              l10n.goPremium,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          error: (_, __) => Text(
                            l10n.goPremium,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                
                // Premium Advantages
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.premiumGoldPale,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.premiumGold.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🚀',
                            style: GoogleFonts.inter(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.premiumAdvantages,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.premiumGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPremiumAdvantage('• ${l10n.unlimitedTests}'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• ${l10n.detailedAnalysis}'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• ${l10n.historyTracking}'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• ${l10n.adFreeExperience}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
