import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../common/burgundy_button.dart';

class GameOverOverlay extends ConsumerWidget {
  final PublicState state;
  final String myPlayerId;
  final VoidCallback onBackToLobby;

  const GameOverOverlay({
    super.key,
    required this.state,
    required this.myPlayerId,
    required this.onBackToLobby,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.status != 'ended') return const SizedBox.shrink();
    final tr = AppLocalizations.of(ref.watch(langProvider));
    final winner = state.players.where((p) => p.id == state.winnerId).firstOrNull;
    final iWon = winner != null && winner.id == myPlayerId;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.92),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti / boom animation behind text
            if (iWon)
              Positioned.fill(
                child: IgnorePointer(
                  child: Lottie.asset(
                    'assets/lottie/confetti.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              )
            else
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.35,
                    child: Lottie.asset(
                      'assets/lottie/boom.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),

            // Foreground content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    iWon ? '🎉' : '💥',
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    winner != null ? tr.wins(winner.name) : tr.gameOverTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: AppColors.crimson, blurRadius: 24),
                        Shadow(color: AppColors.gold, blurRadius: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tr.playAgain,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.goldDim,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 240,
                    child: BurgundyButton(
                      label: tr.backToLobby,
                      onTap: onBackToLobby,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
