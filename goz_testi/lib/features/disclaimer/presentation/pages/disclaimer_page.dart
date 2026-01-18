import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';

/// Legal Disclaimer Page
/// 
/// Displays important legal information about the app's limitations
/// and requires user acknowledgment before proceeding.
class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scrollIndicatorController;
  final ScrollController _scrollController = ScrollController();
  bool _isAccepted = false;
  bool _showScrollIndicator = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    
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
    _controller.dispose();
    _scrollIndicatorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header with Icon
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: _controller,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.warningYellowPale,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.alertTriangle,
                          size: 40,
                          color: AppColors.warningYellow,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.disclaimerTitle,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Disclaimer Content
              Expanded(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.3, 1.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          // Medical Disclaimer Icon Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.errorRedPale,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  LucideIcons.stethoscope,
                                  size: 20,
                                  color: AppColors.errorRed,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tıbbi Uyarı',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.errorRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Main Content
                          Text(
                            AppStrings.disclaimerContent,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Info Cards
                          _buildInfoCard(
                            icon: LucideIcons.info,
                            title: 'Bilgilendirme Amaçlı',
                            description: 'Bu uygulama yalnızca eğitim ve farkındalık amaçlıdır.',
                            color: AppColors.infoBlue,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            icon: LucideIcons.userCheck,
                            title: 'Profesyonel Muayene',
                            description: 'Düzenli göz muayenesi için göz doktorunuzu ziyaret edin.',
                            color: AppColors.medicalTeal,
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
                                            'Aşağı kaydır',
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Checkbox
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.5, 1.0),
                ),
                child: InkWell(
                  onTap: () => setState(() => _isAccepted = !_isAccepted),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isAccepted
                          ? AppColors.medicalBluePale
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isAccepted
                            ? AppColors.medicalBlue
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _isAccepted
                                ? AppColors.medicalBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _isAccepted
                                  ? AppColors.medicalBlue
                                  : AppColors.borderMedium,
                              width: 2,
                            ),
                          ),
                          child: _isAccepted
                              ? const Icon(
                                  LucideIcons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Yukarıdaki uyarıları okudum ve kabul ediyorum',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Accept Button
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _controller,
                  curve: const Interval(0.6, 1.0),
                ),
                child: AppButton(
                  text: AppStrings.acceptAndContinue,
                  onPressed: _isAccepted
                      ? () async {
                          // Save disclaimer acceptance
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('disclaimer_accepted', true);
                          } catch (e) {
                            // Continue even if save fails
                          }
                          if (mounted) {
                            context.go(AppRoutes.home);
                          }
                        }
                      : null,
                  icon: LucideIcons.arrowRight,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
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

