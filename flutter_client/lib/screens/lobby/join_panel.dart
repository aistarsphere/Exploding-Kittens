import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../providers/lobby_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/burgundy_button.dart';
import 'start_panel.dart';

class JoinPanel extends ConsumerStatefulWidget {
  const JoinPanel({super.key});

  @override
  ConsumerState<JoinPanel> createState() => _JoinPanelState();
}

class _JoinPanelState extends ConsumerState<JoinPanel> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final lobby = ref.watch(lobbyProvider);

    return LobbyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr.roomCode, style: const TextStyle(fontSize: 11, letterSpacing: 2, color: AppColors.goldDim, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          TextField(
            autofocus: true,
            maxLength: 4,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            decoration: InputDecoration(hintText: tr.codePlaceholder, counterText: ''),
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 10,
            ),
            onChanged: (v) => ref.read(lobbyProvider.notifier).setCode(v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: BurgundyButton(
                label: tr.join,
                onTap: lobby.loading ? null : () async {
                  final err = await ref.read(lobbyProvider.notifier).onJoinGo();
                  if (err != null && mounted) setState(() => _error = err);
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: BurgundyButton(
                label: tr.back,
                primary: false,
                onTap: () => ref.read(lobbyProvider.notifier).goStart(),
              )),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13, fontFamily: 'Cairo')),
          ],
        ],
      ),
    );
  }
}
