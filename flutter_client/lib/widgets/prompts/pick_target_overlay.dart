import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import 'modal_shell.dart';

class PickTargetOverlay extends ConsumerWidget {
  final String title;
  final PublicState state;
  final String myPlayerId;
  final void Function(String playerId) onPick;
  final VoidCallback onCancel;

  const PickTargetOverlay({
    super.key,
    required this.title,
    required this.state,
    required this.myPlayerId,
    required this.onPick,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final targets = state.players.where((p) => p.alive && p.id != myPlayerId).toList();

    return ModalShell(
      title: tr.pickAPlayer,
      actions: [ModalButton(label: tr.cancel, onTap: onCancel, primary: false)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: targets.map((p) => GestureDetector(
              onTap: () => onPick(p.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                ),
                child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
