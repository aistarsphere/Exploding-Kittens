import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_model.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import 'modal_shell.dart';

const _pickableTypes = [
  CardType.ATTACK, CardType.SKIP, CardType.FAVOR, CardType.SHUFFLE,
  CardType.SEE_THE_FUTURE, CardType.ALTER_THE_FUTURE,
  CardType.DRAW_FROM_BOTTOM, CardType.REVERSE,
  CardType.DOUBLE_SLAP, CardType.TRIPLE_SLAP,
  CardType.NOPE, CardType.DEFUSE,
  CardType.CAT_TACO, CardType.CAT_BEARD, CardType.CAT_RAINBOW,
  CardType.CAT_POTATO, CardType.CAT_MELON, CardType.CAT_FERAL,
];

class CatTrioNameModal extends ConsumerWidget {
  final void Function(Map<String, dynamic>) onRespond;

  const CatTrioNameModal({super.key, required this.onRespond});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);

    return ModalShell(
      title: tr.nameACard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.nameCardTake, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _pickableTypes.map((t) {
              final d = AppLocalizations.getCardDisplay(t, lang);
              return GestureDetector(
                onTap: () => onRespond({'namedType': t.name}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1612),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${d.emoji} ${d.label}',
                    style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
