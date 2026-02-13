import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/services/purchase_service.dart';
import 'package:goz_testi/features/tests/common/presentation/providers/test_provider.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

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

  List<_PremiumFeature> _getFeatures(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _PremiumFeature(
        icon: LucideIcons.unlock,
        title: l10n.premiumFeature1Title,
        description: l10n.premiumFeature1Desc,
      ),
      _PremiumFeature(
        icon: LucideIcons.fileText,
        title: l10n.premiumFeature2Title,
        description: l10n.premiumFeature2Desc,
      ),
      _PremiumFeature(
        icon: LucideIcons.activity,
        title: l10n.premiumFeature3Title,
        description: l10n.premiumFeature3Desc,
      ),
      _PremiumFeature(
        icon: LucideIcons.ban,
        title: l10n.premiumFeature4Title,
        description: l10n.premiumFeature4Desc,
      ),
    ];
  }

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
      final success = await _purchaseService.purchasePremium();
      
      if (!success) {
        if (mounted) {
          setState(() => _isLoading = false);
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.premiumActivationFailed),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      
      // Premium status will be set by PurchaseService when purchase is verified via purchase stream
      // Wait for purchase stream to process (purchase verification happens asynchronously)
      // Poll for premium status update (max 5 seconds)
      bool premiumActivated = false;
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await ref.read(isPremiumProvider.notifier).refresh();
          final isPremium = ref.read(isPremiumProvider);
          if (isPremium) {
            premiumActivated = true;
            break;
          }
        } else {
          return;
        }
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (premiumActivated) {
          // Show premium success banner
          _showPremiumSuccessBanner(context);
          
          // Close paywall after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.pop();
            }
          });
        } else {
          // Premium not activated - purchase may still be processing
          // Keep paywall open, user can check purchase status
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.premiumActivationFailed),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(e.toString())),
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
                      AppLocalizations.of(context)!.premiumActive,
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
                AppLocalizations.of(context)!.premiumActiveDesc,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              _buildBenefitItem(AppLocalizations.of(context)!.premiumBenefit1),
              _buildBenefitItem(AppLocalizations.of(context)!.premiumBenefit2),
              _buildBenefitItem(AppLocalizations.of(context)!.premiumBenefit3),
              _buildBenefitItem(AppLocalizations.of(context)!.premiumBenefit4),
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
              content: Text(AppLocalizations.of(context)!.noRestoreFound),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorOccurred(e.toString())),
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
                      AppLocalizations.of(context)!.restore,
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
                              AppLocalizations.of(context)!.trackEyeHealth,
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
                              AppLocalizations.of(context)!.trackEyeHealthDesc,
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
                    ...List.generate(_getFeatures(context).length, (index) {
                      final feature = _getFeatures(context)[index];
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
                                AppLocalizations.of(context)!.oneTimePayment,
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
                                Consumer(
                                  builder: (context, ref, child) {
                                    final productAsync = ref.watch(premiumProductProvider);
                                    
                                    return productAsync.when(
                                      data: (product) {
                                        // Price comes from App Store/Play Store with correct currency
                                        // e.g., "$0.99", "€0.99", "₺49.99" based on user's country
                                        final price = product?.price ?? '';
                                        
                                        if (price.isNotEmpty) {
                                          return Text(
                                            price,
                                            style: GoogleFonts.inter(
                                              fontSize: 48,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              height: 1,
                                            ),
                                          );
                                        }
                                        
                                        // Product not available (e.g. timeout, sandbox issue) – show label, not endless spinner
                                        return Text(
                                          AppLocalizations.of(context)!.premiumLabel,
                                          style: GoogleFonts.inter(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            height: 1,
                                          ),
                                        );
                                      },
                                      loading: () => const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      error: (_, __) => Text(
                                        'Premium',
                                        style: GoogleFonts.inter(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.lifetimeAccessDesc,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.95),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.singlePaymentNote,
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
                                        AppLocalizations.of(context)!.continueWithPremium,
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
                        AppLocalizations.of(context)!.paywallDisclaimer,
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
                                    AppLocalizations.of(context)!.scrollDown,
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

