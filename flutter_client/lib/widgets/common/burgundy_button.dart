import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BurgundyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool fullWidth;

  const BurgundyButton({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: onTap == null ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          decoration: BoxDecoration(
            gradient: primary ? AppGradients.primaryButton : null,
            color: primary ? null : const Color(0xFF2A1612),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: primary ? AppColors.gold : const Color(0x30F1C40F),
              width: 1,
            ),
            boxShadow: primary
                ? [BoxShadow(color: AppColors.crimson.withOpacity(0.3), blurRadius: 8, spreadRadius: 0)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primary ? Colors.white : AppColors.goldLight,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}
