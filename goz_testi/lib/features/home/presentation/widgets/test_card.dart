import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/constants/app_strings.dart';
import '../pages/home_page.dart';

/// Test Category Card Widget
/// 
/// Displays a single test category with icon, title, description,
/// and premium/free status badge.
class TestCard extends StatelessWidget {
  final TestCategory test;
  final VoidCallback onTap;

  const TestCard({
    super.key,
    required this.test,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = test.isComingSoon;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDisabled 
                ? AppColors.borderLight 
                : test.color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDisabled
                  ? Colors.transparent
                  : test.color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? AppColors.backgroundGrey
                          : test.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      test.icon,
                      size: 26,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : test.color,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  Text(
                    test.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    test.description,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status Row
                  Row(
                    children: [
                      if (test.isComingSoon)
                        _buildBadge(
                          text: 'Yakında',
                          color: AppColors.textTertiary,
                          bgColor: AppColors.backgroundGrey,
                        )
                      else if (test.isPremium)
                        _buildBadge(
                          text: AppStrings.premiumLabel,
                          color: AppColors.premiumGold,
                          bgColor: AppColors.premiumGoldPale,
                          icon: LucideIcons.crown,
                        )
                      else
                        _buildBadge(
                          text: AppStrings.freeLabel,
                          color: AppColors.successGreen,
                          bgColor: AppColors.successGreenPale,
                        ),
                      
                      const Spacer(),
                      
                      if (!isDisabled)
                        Icon(
                          LucideIcons.arrowRight,
                          size: 18,
                          color: test.color,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Coming Soon Overlay
            if (isDisabled)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String text,
    required Color color,
    required Color bgColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

