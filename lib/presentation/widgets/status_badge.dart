import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String color;

  const StatusBadge({required this.label, required this.color, super.key});

  Color _getColor() {
    switch (color) {
      case 'success':
        return AppColors.successBg;
      case 'warning':
        return AppColors.warningBg;
      case 'error':
        return AppColors.errorBg;
      case 'info':
        return AppColors.infoBg;
      case 'secondary':
        return AppColors.muted;
      case 'orange':
        return AppColors.orange.withValues(alpha: 0.12);
      default:
        return AppColors.muted;
    }
  }

  Color _getTextColor() {
    switch (color) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'info':
        return AppColors.info;
      case 'secondary':
        return AppColors.textSecondary;
      case 'orange':
        return AppColors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor(),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getTextColor().withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

