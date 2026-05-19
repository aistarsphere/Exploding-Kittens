import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';

class TurnFlash extends ConsumerWidget {
  final bool visible;

  const TurnFlash({super.key, required this.visible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: visible ? 1.0 : 0.0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: visible ? 1.0 : 0.6,
            child: Text(
              tr.yourTurn,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
                fontFamily: 'Cairo',
                letterSpacing: 2,
                shadows: [
                  Shadow(color: Color(0xFFC0392B), blurRadius: 20, offset: Offset(0, 0)),
                  Shadow(color: Color(0xFFF1C40F), blurRadius: 40, offset: Offset(0, 0)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
