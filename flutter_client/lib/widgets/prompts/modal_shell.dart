import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ModalShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const ModalShell({super.key, required this.title, required this.child, this.actions});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.88),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              gradient: AppGradients.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.7), blurRadius: 40)],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 12),
                  child,
                  if (actions != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!.map((a) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: a,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const ModalButton({super.key, required this.label, this.onTap, this.primary = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: onTap == null ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: primary ? AppGradients.primaryButton : null,
            color: primary ? null : const Color(0xFF2A1612),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: primary ? AppColors.gold : const Color(0x25F1C40F)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: primary ? Colors.white : AppColors.goldLight,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
