import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Rating Service
/// Manages app rating dialog and store redirection
class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  static const String _hasRatedKey = 'has_rated_app';

  /// Check if user has already rated the app
  Future<bool> hasRatedApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasRatedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Mark app as rated
  Future<void> markAsRated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasRatedKey, true);
    } catch (e) {
      // Silently fail
    }
  }

  /// Show rating dialog and handle rating
  /// Returns true if user rated 4-5 stars and store was opened
  Future<bool> showRatingDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if already rated
    final hasRated = await hasRatedApp();
    if (hasRated) {
      return false;
    }

    // Show rating dialog
    final rating = await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _RatingDialog(l10n: l10n),
    );

    // If user dismissed or gave 1-3 stars
    if (rating == null || rating < 4) {
      // Mark as rated even if they gave low rating (so we don't ask again)
      if (rating != null) {
        await markAsRated();
      }
      // Show thank you message for 1-3 stars
      if (rating != null && mounted(context)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.thankYouForFeedback),
            backgroundColor: AppColors.medicalTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }

    // User gave 4 or 5 stars, open store
    await markAsRated();
    final opened = await _openStore(context);
    
    if (opened && mounted(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.thankYouForFeedback),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    return opened;
  }

  Future<bool> _openStore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // App Store / Play Store URLs
    // TODO: Replace with your actual app IDs when published
    const String iosAppId = 'YOUR_IOS_APP_ID'; // Replace with actual App Store ID
    const String androidPackageName = 'com.eyetest.goz_testi'; // Your package name
    
    String url;
    if (Platform.isIOS) {
      // iOS App Store review URL
      url = 'https://apps.apple.com/app/id$iosAppId?action=write-review';
    } else if (Platform.isAndroid) {
      // Android Play Store review URL
      url = 'https://play.google.com/store/apps/details?id=$androidPackageName';
    } else {
      // Web or other platforms - don't show error, just return false
      return false;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      // Silently fail
    }
    
    return false;
  }

  bool mounted(BuildContext context) {
    return context.mounted;
  }
}

/// Rating Dialog Widget
class _RatingDialog extends StatefulWidget {
  final AppLocalizations l10n;

  const _RatingDialog({required this.l10n});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.l10n.rateApp,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              widget.l10n.howWouldYouRateUs,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = starIndex;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      LucideIcons.star,
                      size: 40,
                      color: starIndex <= _selectedRating
                          ? AppColors.premiumGold
                          : AppColors.borderLight,
                      fill: starIndex <= _selectedRating ? 1.0 : 0.0,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.l10n.cancel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedRating == 0
                        ? null
                        : () => Navigator.of(context).pop(_selectedRating),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.medicalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.l10n.submit,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
