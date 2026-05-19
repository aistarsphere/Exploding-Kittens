import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../models/prompt_type.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import 'modal_shell.dart';

class PickPlayerModal extends ConsumerWidget {
  final Prompt prompt;
  final PublicState state;
  final void Function(Map<String, dynamic>) onRespond;

  const PickPlayerModal({super.key, required this.prompt, required this.state, required this.onRespond});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final candidates = (prompt.options['candidates'] as List<dynamic>? ?? []).cast<String>();
    final subtitle = prompt.type == PromptType.catPairTarget ? tr.stealRandom : tr.nameCardSteal;

    return ModalShell(
      title: tr.pickTarget,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: candidates.map((pid) {
              final p = state.players.where((x) => x.id == pid).firstOrNull;
              return GestureDetector(
                onTap: () => onRespond({'targetId': pid}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                  ),
                  child: Text(p?.name ?? pid, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
