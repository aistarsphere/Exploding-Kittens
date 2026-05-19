import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../common/language_toggle.dart';
import '../common/sound_toggle.dart';

class TopBar extends ConsumerWidget {
  final String roomCode;
  final PublicState? state;
  final String myPlayerId;
  final VoidCallback onLeave;

  const TopBar({
    super.key,
    required this.roomCode,
    required this.state,
    required this.myPlayerId,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final isMyTurn = state?.currentPlayerId == myPlayerId;

    String turnText = '…';
    if (state != null) {
      if (state!.status == 'ended') {
        turnText = tr.gameOver;
      } else {
        final cur = state!.players.where((p) => p.id == state!.currentPlayerId).firstOrNull;
        final dir = state!.direction == 1 ? '→' : '←';
        turnText = tr.turnText(cur?.name ?? '?', isMyTurn, state!.remainingTurns, dir);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isMyTurn && state?.status == 'playing'
                ? AppColors.gold.withOpacity(0.6)
                : AppColors.gold.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.goldLight),
              children: [
                TextSpan(text: '${tr.room} '),
                TextSpan(
                  text: roomCode,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              turnText,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.goldLight,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LanguageToggle(),
              const SizedBox(width: 4),
              const SoundToggle(),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onLeave,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.crimson.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tr.leave,
                    style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 12,
                      fontWeight: FontWeight.w700, color: AppColors.goldLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
