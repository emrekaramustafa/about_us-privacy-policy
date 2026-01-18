import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/services/sound_service.dart';
import 'package:goz_testi/core/services/notification_service.dart';
import 'package:goz_testi/core/router/app_router.dart';

/// Settings Page
/// User preferences and app settings
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Ayarlar',
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
            // Ses Ayarları
            _buildSectionTitle('Ses & Bildirimler'),
            _buildSettingTile(
              icon: LucideIcons.volume2,
              title: 'Ses Efektleri',
              subtitle: 'Buton tıklama seslerini aç/kapat',
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
              title: 'Bildirimler',
              subtitle: 'Göz egzersizi hatırlatıcıları',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) async {
                  if (value) {
                    // Request permission first
                    final hasPermission = await _notificationService.requestPermissions();
                    if (!hasPermission) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bildirim izni gerekli'),
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
                  
                  if (mounted && value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bildirimler açıldı'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                activeColor: AppColors.medicalBlue,
              ),
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 8),
              _buildSettingTile(
                icon: LucideIcons.clock,
                title: 'Bildirim Saati',
                subtitle: '${_notificationTime.format(context)}',
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textSecondary,
                ),
                onTap: () => _selectNotificationTime(),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Test Ayarları
            _buildSectionTitle('Test Ayarları'),
            _buildSettingTile(
              icon: LucideIcons.monitor,
              title: 'Parlaklık Uyarısı',
              subtitle: 'Test öncesi ekran parlaklığı uyarısı',
              trailing: Switch(
                value: _brightnessWarningEnabled,
                onChanged: (value) {
                  setState(() {
                    _brightnessWarningEnabled = value;
                  });
                  // TODO: Implement brightness warning
                },
                activeColor: AppColors.medicalBlue,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Bilgi
            _buildSectionTitle('Bilgi'),
            _buildSettingTile(
              icon: LucideIcons.info,
              title: 'Hakkında',
              subtitle: 'Uygulama bilgileri ve versiyon',
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
              title: 'Gizlilik Politikası',
              subtitle: 'Veri kullanımı ve gizlilik',
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
              title: 'Kullanım Koşulları',
              subtitle: 'Hizmet şartları ve koşullar',
              trailing: const Icon(
                LucideIcons.chevronRight,
                color: AppColors.textSecondary,
              ),
              onTap: () {
                context.push(AppRoutes.termsOfService);
              },
            ),
            
            const SizedBox(height: 32),
            
            // Versiyon
            Center(
              child: Text(
                'Versiyon 1.0.0',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Göz Testi',
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
              'Profesyonel göz sağlığı testleri uygulaması',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Versiyon: 1.0.0',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu uygulama bilgilendirme amaçlıdır ve profesyonel göz muayenesi yerine geçmez.',
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
              'Tamam',
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      helpText: 'Bildirim Saati Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      hourLabelText: 'Saat',
      minuteLabelText: 'Dakika',
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
      // Validate time range (08:00 - 22:30)
      if (picked.hour < 8 || (picked.hour == 22 && picked.minute > 30) || picked.hour > 22) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bildirim saati 08:00 - 22:30 arasında olmalıdır'),
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
              content: Text('Bildirim saati ${picked.format(context)} olarak ayarlandı'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
