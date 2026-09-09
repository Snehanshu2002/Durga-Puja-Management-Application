import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusUpper = status.toUpperCase();

    Color bgColor;
    Color textColor;

    switch (statusUpper) {
      case 'APPROVED':
      case 'ACTIVE':
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        break;
      case 'PENDING':
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        break;
      case 'REJECTED':
      case 'INACTIVE':
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        break;
      case 'COMPLETED':
      case 'ARCHIVED':
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        break;
      default:
        bgColor = Colors.blue.withValues(alpha: 0.15);
        textColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusUpper,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
