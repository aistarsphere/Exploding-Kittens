import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/prompt_type.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import 'alter_future_modal.dart';
import 'cat_trio_name_modal.dart';
import 'defuse_reinsert_modal.dart';
import 'favor_give_modal.dart';
import 'modal_shell.dart';
import 'pick_player_modal.dart';
import 'see_future_modal.dart';

class PromptRouter extends ConsumerWidget {
  final PublicState state;
  final String myPlayerId;
  final void Function(Map<String, dynamic>) onRespond;

  const PromptRouter({
    super.key,
    required this.state,
    required this.myPlayerId,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = state.prompt;
    if (prompt == null) return const SizedBox.shrink();

    // If prompt is for someone else
    if (prompt.forPlayerId != myPlayerId) {
      final lang = ref.watch(langProvider);
      final tr = AppLocalizations.of(lang);
      final target = state.players.where((p) => p.id == prompt.forPlayerId).firstOrNull;
      return ModalShell(
        title: tr.waitingFor(target?.name ?? 'player'),
        child: Text(
          tr.respondingTo(prompt.type.name.replaceAll(RegExp(r'([A-Z])'), r' $1').toLowerCase()),
          style: const TextStyle(color: AppColors.goldDim, fontFamily: 'Cairo'),
        ),
      );
    }

    return switch (prompt.type) {
      PromptType.seeFuture     => SeeFutureModal(prompt: prompt, onRespond: onRespond),
      PromptType.alterFuture   => AlterFutureModal(prompt: prompt, onRespond: onRespond),
      PromptType.favorGive     => FavorGiveModal(prompt: prompt, state: state, onRespond: onRespond),
      PromptType.catPairTarget => PickPlayerModal(prompt: prompt, state: state, onRespond: onRespond),
      PromptType.catTrioTarget => PickPlayerModal(prompt: prompt, state: state, onRespond: onRespond),
      PromptType.catTrioName   => CatTrioNameModal(onRespond: onRespond),
      PromptType.defuseReinsert => DefuseReinsertModal(prompt: prompt, onRespond: onRespond),
    };
  }
}
