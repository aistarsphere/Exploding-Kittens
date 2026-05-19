import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import 'modal_shell.dart';

class DefuseReinsertModal extends ConsumerStatefulWidget {
  final Prompt prompt;
  final void Function(Map<String, dynamic>) onRespond;

  const DefuseReinsertModal({super.key, required this.prompt, required this.onRespond});

  @override
  ConsumerState<DefuseReinsertModal> createState() => _DefuseReinsertModalState();
}

class _DefuseReinsertModalState extends ConsumerState<DefuseReinsertModal> {
  late int _pos;
  late int _deckSize;

  @override
  void initState() {
    super.initState();
    _deckSize = (widget.prompt.options['deckSize'] as num?)?.toInt() ?? 0;
    _pos = (_deckSize / 2).floor();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);

    return ModalShell(
      title: tr.defuse,
      actions: [
        ModalButton(
          label: tr.reinsert,
          onTap: () => widget.onRespond({'position': _pos}),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.reinsertKitten, style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: AppColors.surface,
              thumbColor: AppColors.crimson,
              overlayColor: AppColors.crimson.withOpacity(0.2),
            ),
            child: Slider(
              value: _pos.toDouble(),
              min: 0,
              max: _deckSize.toDouble(),
              divisions: _deckSize > 0 ? _deckSize : 1,
              onChanged: (v) => setState(() => _pos = v.round()),
            ),
          ),
          Text(tr.positionFromTop(_pos, _deckSize),
              style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo', fontSize: 13)),
          const SizedBox(height: 4),
          Text(tr.positionHint(_deckSize),
              style: const TextStyle(color: AppColors.goldDim, fontFamily: 'Cairo', fontSize: 11)),
        ],
      ),
    );
  }
}
