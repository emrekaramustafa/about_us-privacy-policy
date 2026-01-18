import 'package:flutter/material.dart';
import 'package:goz_testi/core/theme/app_colors.dart';
import 'package:goz_testi/core/services/sound_service.dart';

/// Primary button widget with consistent styling
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final bool playSound; // Ses çalınsın mı?

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.playSound = true, // Varsayılan olarak ses çal
  });

  void _handlePress() {
    if (playSound && onPressed != null) {
      SoundService().playButtonClick();
    }
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? AppColors.medicalBlue : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (icon != null && !isLoading) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.medicalBlue,
            side: BorderSide(
              color: backgroundColor ?? AppColors.medicalBlue,
              width: 1.5,
            ),
          ),
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.medicalBlue,
          foregroundColor: textColor ?? Colors.white,
          side: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: buttonChild,
      ),
    );
  }
}

/// Direction button for eye tests (used in Snellen test)
class DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool playSound;

  const DirectionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isSelected = false,
    this.playSound = true,
  });

  void _handlePress() {
    if (playSound) {
      SoundService().playButtonClick();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.medicalBluePale : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _handlePress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.medicalBlue : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColors.medicalBlue : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.medicalBlue : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

