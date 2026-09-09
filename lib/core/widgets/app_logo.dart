import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size * 1.5,
        height: size * 1.5,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.temple_hindu,
                color: AppColors.accent,
                size: size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
