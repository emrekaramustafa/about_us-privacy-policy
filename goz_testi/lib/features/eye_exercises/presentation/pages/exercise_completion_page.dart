import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/core/widgets/app_button.dart';
import 'package:goz_testi/core/services/notification_service.dart';
import 'package:goz_testi/core/services/storage_service.dart';

/// Exercise Completion Page
/// Shown when all exercises are completed
class ExerciseCompletionPage extends StatefulWidget {
  final String profile;

  const ExerciseCompletionPage({
    super.key,
    required this.profile,
  });

  @override
  State<ExerciseCompletionPage> createState() => _ExerciseCompletionPageState();
}

class _ExerciseCompletionPageState extends State<ExerciseCompletionPage> {
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _markExerciseCompleted();
  }

  Future<void> _markExerciseCompleted() async {
    final now = DateTime.now();
    
    // Mark in notification service (for notification logic)
    await _notificationService.markExerciseCompleted();
    
    // Save to storage (for history tracking)
    await _storageService.saveExerciseCompletion(widget.profile, now);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration Icon
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.medicalTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle,
                  size: 100,
                  color: AppColors.medicalTeal,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                profile == 'adult' ? '✔ Bugünkü egzersizler tamamlandı' : '🎉 Harika İş Çıkardın!',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Message
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
                child: Column(
                  children: [
                    Text(
                      profile == 'adult'
                          ? 'Gözlerini dinlendirdin\nOdağını yeniledin'
                          : 'Bugünkü göz egzersizlerini tamamladın 👏',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.eye,
                          size: 32,
                          color: AppColors.medicalTeal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '💚',
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile == 'adult'
                          ? 'Gün içinde 1 kez yeterlidir'
                          : 'Gözlerin sana teşekkür ediyor',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Home Button
              AppButton(
                text: 'Ana Ekrana Dön',
                icon: LucideIcons.home,
                onPressed: () => context.go(AppRoutes.home),
                backgroundColor: AppColors.medicalBlue,
              ),
              const SizedBox(height: 16),
              // Restart Button
              AppButton(
                text: 'Egzersizleri Tekrarla',
                icon: LucideIcons.repeat,
                onPressed: () => context.push(
                  AppRoutes.exerciseList,
                  extra: {'profile': profile},
                ),
                isOutlined: true,
                backgroundColor: AppColors.medicalBlue,
                textColor: AppColors.medicalBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
