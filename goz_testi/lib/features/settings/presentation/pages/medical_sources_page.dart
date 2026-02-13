import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Medical Sources / Citations Page
///
/// Lists authoritative sources for the health and vision information
/// shown in the app. Required for App Store Guideline 1.4.1 (Physical Harm).
class MedicalSourcesPage extends StatelessWidget {
  const MedicalSourcesPage({super.key});

  static const List<({String url, String nameEn})> _sources = [
    (url: 'https://www.aao.org/', nameEn: 'American Academy of Ophthalmology'),
    (url: 'https://www.nei.nih.gov/', nameEn: 'NIH National Eye Institute'),
    (url: 'https://www.who.int/news-room/fact-sheets/detail/blindness-and-visual-impairment', nameEn: 'WHO – Blindness and visual impairment'),
  ];

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.medicalSourcesTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.medicalSourcesIntro,
              style: GoogleFonts.inter(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ..._sources.map((s) => _SourceTile(
                  title: _sourceTitle(l10n, s.nameEn),
                  url: s.url,
                  onTap: () => _openUrl(s.url),
                )),
          ],
        ),
      ),
    );
  }

  String _sourceTitle(AppLocalizations l10n, String nameEn) {
    switch (nameEn) {
      case 'American Academy of Ophthalmology':
        return l10n.sourceAao;
      case 'NIH National Eye Institute':
        return l10n.sourceNei;
      case 'WHO – Blindness and visual impairment':
        return l10n.sourceWho;
      default:
        return nameEn;
    }
  }
}

class _SourceTile extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;

  const _SourceTile({
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.externalLink, size: 20, color: AppColors.medicalBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
