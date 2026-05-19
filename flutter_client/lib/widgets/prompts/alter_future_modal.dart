import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_model.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../card/game_card.dart';
import 'modal_shell.dart';

class AlterFutureModal extends ConsumerStatefulWidget {
  final Prompt prompt;
  final void Function(Map<String, dynamic>) onRespond;

  const AlterFutureModal({super.key, required this.prompt, required this.onRespond});

  @override
  ConsumerState<AlterFutureModal> createState() => _AlterFutureModalState();
}

class _AlterFutureModalState extends ConsumerState<AlterFutureModal> {
  late List<CardModel> _remaining;
  late List<CardModel> _order;
  late List<CardModel> _initial;

  @override
  void initState() {
    super.initState();
    _initial = (widget.prompt.options['cards'] as List<dynamic>? ?? [])
        .map((c) => CardModel.fromJson(Map<String, dynamic>.from(c as Map)))
        .toList();
    _remaining = List.from(_initial);
    _order = [];
  }

  void _pick(CardModel c) {
    setState(() {
      _remaining.removeWhere((x) => x.id == c.id);
      _order.add(c);
    });
  }

  void _reset() => setState(() { _remaining = List.from(_initial); _order = []; });

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final done = _order.length == _initial.length;

    return ModalShell(
      title: tr.alterFuture,
      actions: [
        ModalButton(label: tr.reset, onTap: _reset, primary: false),
        ModalButton(
          label: tr.confirm,
          onTap: done ? () => widget.onRespond({'order': _order.map((c) => c.id).toList()}) : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.clickCardsOrder, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _remaining.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GameCard(card: c, width: 72, height: 100, onTap: () => _pick(c)),
              )).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(tr.newOrder, style: const TextStyle(color: AppColors.goldDim, fontFamily: 'Cairo', fontSize: 11, fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _order.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GameCard(card: c, width: 72, height: 100),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
