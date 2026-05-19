import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_model.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../card/card_hand.dart';

class HandSection extends ConsumerWidget {
  final List<CardModel> hand;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;
  final VoidCallback onPlaySelected;
  final VoidCallback onDraw;
  final bool canAct;
  final bool isMyTurn;

  const HandSection({
    super.key,
    required this.hand,
    required this.selectedIds,
    required this.onToggle,
    required this.onPlaySelected,
    required this.onDraw,
    required this.canAct,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgDeep.withOpacity(0),
            AppColors.bgDeep.withOpacity(0.9),
            AppColors.bgDeep,
          ],
          stops: const [0, 0.25, 1],
        ),
        border: isMyTurn
            ? Border(top: BorderSide(color: AppColors.gold.withOpacity(0.4), width: 1))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CardHand(hand: hand, selectedIds: selectedIds, onToggle: onToggle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: tr.playSelected,
                    enabled: canAct && selectedIds.isNotEmpty,
                    onTap: onPlaySelected,
                    primary: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: tr.drawEndTurn,
                    enabled: canAct,
                    onTap: onDraw,
                    primary: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({required this.label, required this.enabled, required this.onTap, required this.primary});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.35,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            gradient: primary && enabled ? AppGradients.primaryButton : null,
            color: primary && enabled ? null : const Color(0xFF2A1612),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: primary && enabled ? AppColors.gold : const Color(0x25F1C40F),
            ),
            boxShadow: enabled
                ? [BoxShadow(color: AppColors.crimson.withOpacity(0.25), blurRadius: 6)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: enabled ? Colors.white : AppColors.goldDim,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.8,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}
