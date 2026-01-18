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
    setState(() => _isLoading = true);

    // Try to load ad if not ready
    if (!_adService.isRewardedAdReady) {
      await _adService.loadRewardedAd();
    }

    final success = await _adService.showRewardedAd(
      context: context,
      onRewarded: () async {
        // Grant +1 test credit
        await _storageService.addExtraTestCredit();
        
        // Refresh daily count
        ref.invalidate(dailyTestCountProvider);
        
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('+1 test hakkı kazandınız!'),
              backgroundColor: AppColors.successGreen,
              duration: Duration(seconds: 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam gösterilemedi. Lütfen tekrar deneyin.'),
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
          'Günlük Test Bilgisi',
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
                    final dailyCountAsync = ref.watch(dailyTestCountProvider);
                    
                    return dailyCountAsync.when(
                      data: (count) {
                        final remaining = (3 - count).clamp(0, 3);
                        return Text(
                          'Bugün reklamsız yapabileceğin test sayısı: $remaining',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        );
                      },
                      loading: () => Text(
                        'Bugün reklamsız yapabileceğin test sayısı: 3',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      error: (_, __) => Text(
                        'Bugün reklamsız yapabileceğin test sayısı: 3',
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
                    final dailyCountAsync = ref.watch(dailyTestCountProvider);
                    
                    return dailyCountAsync.when(
                      data: (count) {
                        final remaining = 3 - count;
                        return InkWell(
                          onTap: _watchAd,
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
                                    Text(
                                      'Video izle, +1 test hakkı kazan.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.medicalBlue,
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
                                  'Kalan hak: $remaining',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.medicalBlue.withOpacity(0.8),
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
                            'Bilgi',
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
                        'Reklamsız test haklarınız her gün yenilenir. Reklam izleyerek sınırsız test ve egzersiz yapabilirsiniz.',
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
                  text: _isLoading ? 'Reklam Yükleniyor...' : 'Reklam İzle (+1 Test)',
                  icon: _isLoading ? null : LucideIcons.playCircle,
                  onPressed: _isLoading ? null : _watchAd,
                  width: double.infinity,
                  backgroundColor: AppColors.medicalBlue,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                
                // Continue Button
                AppButton(
                  text: 'Devam Et',
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
                  child: TextButton(
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
                    child: Text(
                      'Premium Ol - Ömür Boyu Sadece ₺79.99',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
                            'Premium avantajları:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.premiumGold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPremiumAdvantage('• Sınırsız test ve egzersiz'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• Detaylı görme analizi'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• Geçmiş kayıtlarınız'),
                      const SizedBox(height: 8),
                      _buildPremiumAdvantage('• Reklamsız kullanım'),
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
