import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/widgets/scroll_indicator.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Terms of Service Page
/// 
/// Displays the terms of service and usage conditions
class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.termsOfServiceTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 32),
                  _buildSection(
                    title: l10n.termsSection1Title,
                    content: l10n.termsSection1Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection2Title,
                    content: l10n.termsSection2Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection3Title,
                    content: l10n.termsSection3Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection4Title,
                    content: l10n.termsSection4Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection5Title,
                    content: l10n.termsSection5Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection6Title,
                    content: l10n.termsSection6Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection7Title,
                    content: l10n.termsSection7Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection8Title,
                    content: l10n.termsSection8Content,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection9Title,
                    content: l10n.termsSection9Content(DateTime.now().year),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: l10n.termsSection10Title,
                    content: l10n.termsSection10Content,
                  ),
                  const SizedBox(height: 32),
                  _buildDisclaimer(l10n),
                ],
              ),
            ),
          ),
          ScrollIndicator(scrollController: _scrollController),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.medicalTeal.withOpacity(0.1),
            AppColors.medicalBlue.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.medicalTeal.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.medicalTeal.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.fileText,
              size: 32,
              color: AppColors.medicalTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.termsOfServiceTitle,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.termsOfServiceSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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

  Widget _buildSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningYellow.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 32,
            color: AppColors.warningYellow,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.termsImportantWarning,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.termsDisclaimer,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
