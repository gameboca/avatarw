import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import 'cyber_button.dart';

class RateUsDialog extends StatefulWidget {
  const RateUsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const RateUsDialog(),
    );
  }

  @override
  State<RateUsDialog> createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<RateUsDialog>
    with SingleTickerProviderStateMixin {
  int _rating = 5; // Default to 5 stars for high conversion
  bool _submitted = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _reactionEmoji {
    switch (_rating) {
      case 5:
        return '🤩';
      case 4:
        return '😊';
      case 3:
        return '🙂';
      case 2:
        return '😐';
      case 1:
        return '🥺';
      default:
        return '⭐';
    }
  }

  String get _reactionTitle {
    switch (_rating) {
      case 5:
        return 'ABSOLUTELY LEGENDARY!';
      case 4:
        return 'WE LOVE YOUR SUPPORT!';
      case 3:
        return 'GOOD EXPERIENCE?';
      case 2:
        return 'HOW CAN WE IMPROVE?';
      case 1:
        return 'WE HEAR YOU';
      default:
        return AppStrings.stampTheForge;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(26.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _rating == 5
                ? AppColors.neonAmber.withValues(alpha: 0.6)
                : AppColors.primary.withValues(alpha: 0.4),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (_rating == 5 ? AppColors.neonAmber : AppColors.primary)
                  .withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: _submitted ? _buildThankYou() : _buildRatingForm(),
      ),
    );
  }

  Widget _buildRatingForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated reaction circle
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _rating == 5
                    ? AppColors.neonAmber.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.2),
                AppColors.surfaceElevated,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: _rating == 5
                  ? AppColors.neonAmber
                  : AppColors.primaryLight,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _reactionEmoji,
              style: const TextStyle(fontSize: 38),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          _reactionTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Your feedback directly calibrates every custom kit on the bench.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 22),

        // Glowing 5 Stars
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isFilled = starNumber <= _rating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starNumber;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedScale(
                    scale: isFilled ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isFilled
                          ? AppColors.neonAmber
                          : AppColors.textMuted,
                      size: 38,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 26),

        CyberButton(
          text: _rating == 5 ? 'STAMP 5 STARS ⭐' : 'SUBMIT VERDICT',
          color: _rating == 5 ? AppColors.neonAmber : AppColors.primary,
          onPressed: () {
            setState(() {
              _submitted = true;
            });
          },
        ),

        const SizedBox(height: 10),

        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'MAYBE LATER',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThankYou() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonGreen, width: 2),
          ),
          child: const Icon(
            Icons.celebration_rounded,
            color: AppColors.neonGreen,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'VERDICT LOGGED!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thank you for calibrating the Avatar Forge! Your verdict has been registered.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        CyberButton(
          text: 'CONTINUE BUILDING',
          color: AppColors.neonGreen,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
