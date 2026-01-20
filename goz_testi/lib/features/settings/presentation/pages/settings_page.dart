import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/l10n/app_localizations.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/services/sound_service.dart';
import 'package:goz_testi/core/services/notification_service.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/providers/locale_provider.dart';
import 'package:goz_testi/core/services/rating_service.dart';

/// Settings Page
/// User preferences and app settings
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final NotificationService _notificationService = NotificationService();
  bool _soundEnabled = true;
  bool _notificationsEnabled = true;
  bool _brightnessWarningEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 16, minute: 30);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final soundEnabled = SoundService().isEnabled;
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    final notificationTime = await _notificationService.getNotificationTime();
    
    setState(() {
      _soundEnabled = soundEnabled;
      _notificationsEnabled = notificationsEnabled;
      _notificationTime = notificationTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Language Settings
            _buildSectionTitle(l10n.language),
            _buildSettingTile(
              icon: LucideIcons.globe,
              title: l10n.language,
              subtitle: currentLocale != null 
                  ? '${SupportedLocales.getFlag(currentLocale)} ${SupportedLocales.getLanguageName(currentLocale)}'
                  : '🌐 Auto (${SupportedLocales.getLanguageName(Localizations.localeOf(context))})',
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () => _showLanguageSelector(),
            ),
            
            const SizedBox(height: 32),
            
            // Sound & Notifications
            _buildSectionTitle(l10n.notifications),
            _buildSettingTile(
              icon: LucideIcons.volume2,
              title: l10n.soundEffects,
              subtitle: l10n.soundEffectsDesc,
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                  SoundService().setEnabled(value);
                },
                activeColor: AppColors.medicalBlue,
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: LucideIcons.bell,
              title: l10n.notifications,
              subtitle: l10n.dailyReminder,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  if (value) {
                    final hasPermission = await _notificationService.requestPermissions();
                    if (!hasPermission) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.errorGeneric),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                  }
                  
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  await _notificationService.setNotificationsEnabled(value);
                },
                activeColor: AppColors.medicalBlue,
              ),
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 8),
              _buildSettingTile(
                icon: LucideIcons.clock,
                title: l10n.notificationTime,
                subtitle: _notificationTime.format(context),
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSecondary,
                ),
                onTap: () => _selectNotificationTime(),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Test Settings
            _buildSectionTitle(l10n.testSection),
            _buildSettingTile(
              icon: LucideIcons.monitor,
              title: l10n.brightnessWarning,
              subtitle: l10n.brightnessWarningDesc,
              trailing: Switch(
                value: _brightnessWarningEnabled,
                onChanged: (value) {
                  setState(() {
                    _brightnessWarningEnabled = value;
                  });
                },
                activeColor: AppColors.medicalBlue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Information
            _buildSectionTitle(l10n.about),
            _buildSettingTile(
              icon: LucideIcons.info,
              title: l10n.about,
              subtitle: '${l10n.version} 1.0.0',
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                _showAboutDialog();
              },
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: LucideIcons.shield,
              title: l10n.privacyPolicy,
              subtitle: l10n.privacy,
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                context.push(AppRoutes.privacyPolicy);
              },
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: LucideIcons.fileText,
              title: l10n.termsOfService,
              subtitle: l10n.terms,
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                context.push(AppRoutes.termsOfService);
              },
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              icon: LucideIcons.star,
              title: l10n.rateApp,
              subtitle: l10n.rateApp,
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                _rateApp();
              },
            ),
            
            const SizedBox(height: 32),
            
            // Version
            Center(
              child: Text(
                '${l10n.version} 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(localeProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.language,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Scrollable language list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Auto option
                    _buildLanguageOption(
                      flag: '🌐',
                      name: 'Auto (${SupportedLocales.getLanguageName(Localizations.localeOf(context))})',
                      isSelected: currentLocale == null,
                      onTap: () {
                        ref.read(localeProvider.notifier).clearLocale();
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    // Language options
                    ...SupportedLocales.all.map((locale) => _buildLanguageOption(
                      flag: SupportedLocales.getFlag(locale),
                      name: SupportedLocales.getLanguageName(locale),
                      isSelected: currentLocale?.languageCode == locale.languageCode,
                      onTap: () {
                        ref.read(localeProvider.notifier).setLocale(locale);
                        Navigator.pop(context);
                      },
                    )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.medicalBlue : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                LucideIcons.check,
                color: AppColors.medicalBlue,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.medicalBluePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.medicalBlue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.appName,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTagline,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.version}: 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.informationalPurposeDesc,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.okay,
              style: GoogleFonts.inter(
                color: AppColors.medicalBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectNotificationTime() async {
    final l10n = AppLocalizations.of(context)!;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      helpText: l10n.dailyReminder,
      cancelText: l10n.cancel,
      confirmText: l10n.okay,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.medicalBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (picked.hour < 8 || (picked.hour == 22 && picked.minute > 30) || picked.hour > 22) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorGeneric),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        await _notificationService.setNotificationTime(picked);
        setState(() {
          _notificationTime = picked;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.success}: ${picked.format(context)}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorGeneric),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _rateApp() async {
    final ratingService = RatingService();
    await ratingService.showRatingDialog(context);
  }
}
