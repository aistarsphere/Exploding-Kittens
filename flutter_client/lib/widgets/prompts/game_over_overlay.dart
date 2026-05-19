import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../common/burgundy_button.dart';

class GameOverOverlay extends ConsumerWidget {
  final PublicState state;
  final VoidCallback onBackToLobby;

  const GameOverOverlay({super.key, required this.state, required this.onBackToLobby});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.status != 'ended') return const SizedBox.shrink();
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final winner = state.players.where((p) => p.id == state.winnerId).firstOrNull;

    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              winner != null ? tr.wins(winner.name) : tr.gameOverTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
                shadows: [Shadow(color: Color(0xFFC0392B), blurRadius: 30)],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr.playAgain,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.goldDim, fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: BurgundyButton(label: tr.backToLobby, onTap: onBackToLobby),
            ),
          ],
        ),
      ),
    );
  }
}
