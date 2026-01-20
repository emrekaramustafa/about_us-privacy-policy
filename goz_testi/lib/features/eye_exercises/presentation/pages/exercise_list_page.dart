import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/router/app_router.dart';
import 'package:goz_testi/features/eye_exercises/domain/models/exercise_model.dart';
import 'package:goz_testi/features/eye_exercises/domain/models/exercise_localizations.dart';
import 'package:goz_testi/l10n/app_localizations.dart';

/// Exercise List Page
/// Shows list of exercises for selected profile
class ExerciseListPage extends StatelessWidget {
  final String profile;

  const ExerciseListPage({
    super.key,
    required this.profile,
  });

  List<ExerciseModel> _getExercises() {
    switch (profile) {
      case 'child':
        return ExerciseData.getChildExercises();
      case 'adult':
        return ExerciseData.getAdultExercises();
      case 'office':
        return ExerciseData.getOfficeExercises();
      default:
        return ExerciseData.getAdultExercises();
    }
  }

  String _getProfileTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (profile) {
      case 'child':
        return l10n.exerciseProfileChildFull;
      case 'adult':
        return l10n.exerciseProfileAdultFull;
      case 'office':
        return l10n.exerciseProfileOffice;
      default:
        return l10n.exerciseProfileAdult;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercises = _getExercises();

    return Scaffold(
      backgroundColor: AppColors.cleanWhite,
      appBar: AppBar(
        backgroundColor: AppColors.cleanWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _getProfileTitle(context),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    l10n.exerciseTodayExercises,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.exerciseSteps(exercises.length),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return _ExerciseCard(
                    exercise: exercise,
                    index: index + 1,
                    onTap: () => context.push(
                      AppRoutes.exerciseDetail,
                      extra: {
                        'exercise': exercise,
                        'profile': profile,
                        'exerciseIndex': index,
                        'totalExercises': exercises.length,
                      },
                    ),
                  );
                },
              ),
            ),
            // Start Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => context.push(
                  AppRoutes.exerciseDetail,
                  extra: {
                    'exercise': exercises[0],
                    'profile': profile,
                    'exerciseIndex': 0,
                    'totalExercises': exercises.length,
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play),
                    const SizedBox(width: 8),
                    Text(
                      l10n.exerciseStartExercises,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final int index;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            // Index Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.medicalBluePale,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.medicalBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Emoji veya Icon
            if (exercise.type == ExerciseType.figureEight) ...[
              Icon(
                LucideIcons.infinity,
                size: 32,
                color: AppColors.medicalTeal,
              ),
            ] else if (exercise.emoji.isNotEmpty) ...[
              Text(
                exercise.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ],
            const SizedBox(width: 16),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ExerciseLocalizations.getTitle(context, exercise.id),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ExerciseLocalizations.getDescription(context, exercise.id).split('\n').first,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
