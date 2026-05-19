import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';

class OpponentsRow extends ConsumerWidget {
  final PublicState state;
  final String myPlayerId;

  const OpponentsRow({super.key, required this.state, required this.myPlayerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final opponents = state.players.where((p) => p.id != myPlayerId).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: opponents.map((p) {
          final isActive = state.currentPlayerId == p.id;
          final cnt = state.handCounts[p.id] ?? 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: const BoxConstraints(minWidth: 80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF2A1612), Color(0xFF1A0806)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? AppColors.gold : AppColors.gold.withOpacity(0.15),
                width: isActive ? 1.5 : 1,
              ),
              boxShadow: isActive
                  ? [BoxShadow(color: AppColors.gold.withOpacity(0.35), blurRadius: 10, spreadRadius: 0)]
                  : null,
            ),
            child: Opacity(
              opacity: p.alive ? 1.0 : 0.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                      decoration: p.alive ? null : TextDecoration.lineThrough,
                      decorationColor: AppColors.goldLight,
                    ),
                  ),
                  Text(
                    '${tr.cards(cnt)}${p.alive ? '' : ' ${tr.out}'}',
                    style: const TextStyle(
                      color: AppColors.goldDim, fontSize: 11, fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
