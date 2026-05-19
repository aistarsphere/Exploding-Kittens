import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../card/game_card.dart';

class TableSection extends ConsumerWidget {
  final PublicState? state;

  const TableSection({super.key, this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Draw pile
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const GameCard(faceDown: true, width: 80, height: 112),
                  Text(
                    '${state?.deckCount ?? 0}',
                    style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppColors.gold, fontFamily: 'Cairo',
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(tr.draw, style: const TextStyle(fontSize: 10, color: AppColors.goldDim, fontFamily: 'Cairo', letterSpacing: 1)),
            ],
          ),
          const SizedBox(width: 24),
          // Discard pile
          Column(
            children: [
              state?.topDiscard != null
                  ? GameCard(card: state!.topDiscard, width: 80, height: 112)
                  : Container(
                      width: 80, height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withOpacity(0.2), width: 1.5),
                        color: AppColors.surface.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          tr.discard,
                          style: const TextStyle(
                            fontSize: 11, color: AppColors.goldDim,
                            fontFamily: 'Cairo', letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 4),
              Text(tr.discard, style: const TextStyle(fontSize: 10, color: AppColors.goldDim, fontFamily: 'Cairo', letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}
