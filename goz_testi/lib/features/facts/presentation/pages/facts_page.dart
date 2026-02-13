import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Facts Page - "Biliyor muydunuz?" section
class FactsPage extends StatefulWidget {
  const FactsPage({super.key});

  @override
  State<FactsPage> createState() => _FactsPageState();
}

class _FactsPageState extends State<FactsPage> {
  int _currentFactIndex = 0;
  
  List<Map<String, dynamic>> _getFacts(AppLocalizations l10n) => [
    {
      'title': l10n.fact1Title,
      'fact': l10n.fact1Text,
      'icon': LucideIcons.monitor,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact2Title,
      'fact': l10n.fact2Text,
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact3Title,
      'fact': l10n.fact3Text,
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact4Title,
      'fact': l10n.fact4Text,
      'icon': LucideIcons.moon,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact5Title,
      'fact': l10n.fact5Text,
      'icon': LucideIcons.palette,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact6Title,
      'fact': l10n.fact6Text,
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact7Title,
      'fact': l10n.fact7Text,
      'icon': LucideIcons.sparkles,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact8Title,
      'fact': l10n.fact8Text,
      'icon': LucideIcons.rainbow,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact9Title,
      'fact': l10n.fact9Text,
      'icon': LucideIcons.move,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact10Title,
      'fact': l10n.fact10Text,
      'icon': LucideIcons.cpu,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact11Title,
      'fact': l10n.fact11Text,
      'icon': LucideIcons.moonStar,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact12Title,
      'fact': l10n.fact12Text,
      'icon': LucideIcons.sparkles,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact13Title,
      'fact': l10n.fact13Text,
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact14Title,
      'fact': l10n.fact14Text,
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact15Title,
      'fact': l10n.fact15Text,
      'icon': LucideIcons.moon,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact16Title,
      'fact': l10n.fact16Text,
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact17Title,
      'fact': l10n.fact17Text,
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact18Title,
      'fact': l10n.fact18Text,
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact19Title,
      'fact': l10n.fact19Text,
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact20Title,
      'fact': l10n.fact20Text,
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact21Title,
      'fact': l10n.fact21Text,
      'icon': LucideIcons.sparkles,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact22Title,
      'fact': l10n.fact22Text,
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact23Title,
      'fact': l10n.fact23Text,
      'icon': LucideIcons.eye,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact24Title,
      'fact': l10n.fact24Text,
      'icon': LucideIcons.waves,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact25Title,
      'fact': l10n.fact25Text,
      'icon': LucideIcons.eye,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact26Title,
      'fact': l10n.fact26Text,
      'icon': LucideIcons.heart,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact27Title,
      'fact': l10n.fact27Text,
      'icon': LucideIcons.eye,
      'color': AppColors.premiumGold,
    },
    {
      'title': l10n.fact28Title,
      'fact': l10n.fact28Text,
      'icon': LucideIcons.waves,
      'color': AppColors.medicalBlue,
    },
    {
      'title': l10n.fact29Title,
      'fact': l10n.fact29Text,
      'icon': LucideIcons.moon,
      'color': AppColors.medicalTeal,
    },
    {
      'title': l10n.fact30Title,
      'fact': l10n.fact30Text,
      'icon': LucideIcons.moon,
      'color': AppColors.premiumGold,
    },
  ];

  void _nextFact() {
    final l10n = AppLocalizations.of(context)!;
    final facts = _getFacts(l10n);
    if (_currentFactIndex < facts.length - 1) {
      setState(() {
        _currentFactIndex++;
      });
    } else {
      // Go back to home or show completion
      context.pop();
    }
  }

  void _previousFact() {
    if (_currentFactIndex > 0) {
      setState(() {
        _currentFactIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final facts = _getFacts(l10n);
    final currentFact = facts[_currentFactIndex];
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.didYouKnow,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${_currentFactIndex + 1} / ${facts.length}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentFactIndex + 1) / facts.length,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: AlwaysStoppedAnimation<Color>(currentFact['color']),
              minHeight: 4,
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: (currentFact['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          currentFact['icon'],
                          size: 64,
                          color: currentFact['color'],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      currentFact['title'],
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Fact text
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        currentFact['fact'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Medical sources citation (Guideline 1.4.1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push(AppRoutes.medicalSources),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.medicalBlue.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.bookOpen, size: 18, color: AppColors.medicalBlue),
                              const SizedBox(width: 8),
                              Text(
                                l10n.viewSources,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.medicalBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Navigation buttons
                    Row(
                      children: [
                        if (_currentFactIndex > 0)
                          Expanded(
                            child: AppButton(
                              text: l10n.factPrevious,
                              icon: LucideIcons.arrowLeft,
                              onPressed: _previousFact,
                              isOutlined: true,
                              backgroundColor: currentFact['color'],
                              textColor: currentFact['color'],
                            ),
                          ),
                        if (_currentFactIndex > 0) const SizedBox(width: 16),
                        Expanded(
                          child: AppButton(
                            text: _currentFactIndex < facts.length - 1
                                ? l10n.factNext
                                : l10n.factComplete,
                            icon: _currentFactIndex < facts.length - 1
                                ? LucideIcons.arrowRight
                                : LucideIcons.check,
                            onPressed: _nextFact,
                            backgroundColor: currentFact['color'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

