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
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: ref.read(lobbyProvider).code);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(ref.watch(langProvider));
    final lobby = ref.watch(lobbyProvider);

    return LobbyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr.roomCode,
            style: const TextStyle(
              fontSize: 11, letterSpacing: 2,
              color: AppColors.goldDim, fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 4,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: tr.codePlaceholder,
              counterText: '',
            ),
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 10,
            ),
            onChanged: (v) => ref.read(lobbyProvider.notifier).setCode(v),
            onSubmitted: (_) => _onJoin(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BurgundyButton(
                  label: tr.join,
                  onTap: lobby.loading ? null : _onJoin,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BurgundyButton(
                  label: tr.back,
                  primary: false,
                  onTap: lobby.loading
                      ? null
                      : () => ref.read(lobbyProvider.notifier).goStart(),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.errorRed, fontSize: 13, fontFamily: 'Cairo',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onJoin() async {
    setState(() => _error = null);
    final err = await ref.read(lobbyProvider.notifier).onJoinGo();
    if (err != null && mounted) setState(() => _error = err);
  }
}
