import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/services/purchase_service.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';

/// Paywall Page
/// 
/// Displays premium features and purchase options.
/// Acts as a gate for premium tests and PDF reports.
class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scrollIndicatorController;
  final ScrollController _scrollController = ScrollController();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;
  bool _showScrollIndicator = true;

  final List<_PremiumFeature> _features = [
    _PremiumFeature(
      icon: LucideIcons.unlock,
      title: 'Tüm testleri sınırsız yap',
      description: 'Görme durumunu farklı zamanlarda ölç',
    ),
    _PremiumFeature(
      icon: LucideIcons.fileText,
      title: 'Detaylı raporlar & karşılaştırmalar',
      description: 'Önceki sonuçlarla farkları gör',
    ),
    _PremiumFeature(
      icon: LucideIcons.activity,
      title: 'Egzersiz geçmişi & takip',
      description: 'Günlük egzersizlerini kaydet ve ilerlemeyi gör',
    ),
    _PremiumFeature(
      icon: LucideIcons.ban,
      title: 'Reklamsız, kesintisiz deneyim',
      description: 'Testlere daha rahat odaklan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    
    _scrollIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      final currentScroll = _scrollController.position.pixels;
      
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
    _animationController.dispose();
    _scrollIndicatorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onPurchase() async {
    setState(() => _isLoading = true);
    
    try {
      // TEST MODE: Directly grant premium without payment
      final success = await _purchaseService.purchasePremium();
      
      if (!success) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Premium aktif edilemedi. Lütfen tekrar deneyin.'),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      // TEST MODE: Set premium status in provider (NOT persisted - resets on app restart)
      await ref.read(isPremiumProvider.notifier).setPremium(true);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Show premium success banner first
        _showPremiumSuccessBanner(context);
        
        // Close paywall after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPremiumSuccessBanner(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.checkCircle,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🎉 Premium Aktif!',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Artık tüm premium özelliklerden faydalanabilirsiniz:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              _buildBenefitItem('✓ Sınırsız test ve egzersiz'),
              _buildBenefitItem('✓ Detaylı görme analizi'),
              _buildBenefitItem('✓ Geçmiş kayıtlarınız'),
              _buildBenefitItem('✓ Reklamsız kullanım'),
            ],
          ),
        ),
        backgroundColor: AppColors.premiumGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onRestore() async {
    setState(() => _isLoading = true);
    
    try {
      await _purchaseService.restorePurchases();
      
      // Check if premium was restored
      final hasActivePurchase = await _purchaseService.hasActivePurchase();
      
      if (hasActivePurchase) {
        await ref.read(isPremiumProvider.notifier).setPremium(true);
        
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Show premium success banner first
          _showPremiumSuccessBanner(context);
          
          // Close paywall after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.pop();
            }
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Geri yüklenecek satın alma bulunamadı.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is already premium and close if so
    final isPremium = ref.watch(isPremiumProvider);
    if (isPremium) {
      // Close paywall if user is already premium
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop();
        }
      });
    }
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => context.pop(),
                    color: AppColors.textSecondary,
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _onRestore,
                    child: Text(
                      'Satın Alımı Geri Yükle',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    // Title Section
                    FadeTransition(
                      opacity: _animationController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOut,
                        )),
                        child: Column(
                          children: [
                            Text(
                              'Göz Sağlığını Takip Et',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Testlerini karşılaştır, günlük egzersizlerini yap, reklamsız, kesintisiz kullan',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Features List
                    ...List.generate(_features.length, (index) {
                      final feature = _features[index];
                      final delay = 0.1 * index;
                      
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            0.2 + delay,
                            0.7 + delay,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.2, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              0.2 + delay,
                              0.7 + delay,
                              curve: Curves.easeOut,
                            ),
                          )),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildFeatureRow(feature),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 32),
                    
                    // Pricing Card
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.5, 1.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.premiumGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.premiumGold.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Tek Seferlik Ödeme',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₺',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '79',
                                  style: GoogleFonts.inter(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  '.99',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ömür boyu erişim',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tek sefer öde • Güncellemeler dahil',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onPurchase,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.premiumGold,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.premiumGold,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Premium ile Devam Et',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.premiumGold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Disclaimer
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.7, 1.0),
                      ),
                      child: Text(
                        'Bu uygulama tıbbi teşhis koymaz. Testler bilgilendirme ve takip amaçlıdır.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
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
                                    color: AppColors.premiumGold,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Aşağı kaydır',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.premiumGold,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(_PremiumFeature feature) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.medicalBluePale,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.medicalBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            LucideIcons.check,
            color: AppColors.successGreen,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

