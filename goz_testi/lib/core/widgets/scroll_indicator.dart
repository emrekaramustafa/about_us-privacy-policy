import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:goz_testi/core/theme/app_colors.dart';

/// Scroll Indicator Widget
/// 
/// Shows a fade gradient and animated scroll indicator at the bottom
/// of scrollable content to indicate more content below
class ScrollIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final Color? indicatorColor;
  final String? text;

  const ScrollIndicator({
    super.key,
    required this.scrollController,
    this.indicatorColor,
    this.text,
  });

  @override
  State<ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showIndicator = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentScroll = widget.scrollController.position.pixels;
    
    if (currentScroll > 50) {
      if (_showIndicator) {
        setState(() => _showIndicator = false);
      }
    } else {
      if (!_showIndicator) {
        setState(() => _showIndicator = true);
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showIndicator) return const SizedBox.shrink();

    final color = widget.indicatorColor ?? AppColors.medicalBlue;
    final text = widget.text ?? 'Aşağı kaydır';

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FadeTransition(
                opacity: _animationController,
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.chevronDown,
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
