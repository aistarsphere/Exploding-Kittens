import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_model.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../card/game_card.dart';
import 'modal_shell.dart';

class FavorGiveModal extends ConsumerWidget {
  final Prompt prompt;
  final PublicState state;
  final void Function(Map<String, dynamic>) onRespond;

  const FavorGiveModal({super.key, required this.prompt, required this.state, required this.onRespond});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final cards = (prompt.options['cards'] as List<dynamic>? ?? [])
        .map((c) => CardModel.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
    final target = state.players.where((p) => p.id == prompt.options['toPlayerId']).firstOrNull;

    return ModalShell(
      title: tr.favor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.giveCardTo(target?.name ?? '?'),
              style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GameCard(card: c, width: 80, height: 112, onTap: () => onRespond({'cardId': c.id})),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
