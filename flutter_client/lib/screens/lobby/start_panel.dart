import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../providers/lobby_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/burgundy_button.dart';

class StartPanel extends ConsumerStatefulWidget {
  const StartPanel({super.key});

  @override
  ConsumerState<StartPanel> createState() => _StartPanelState();
}

class _StartPanelState extends ConsumerState<StartPanel> {
  String? _error;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(lobbyProvider).name;
    _ctrl = TextEditingController(text: initial);
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

    // Sync controller with provider value if it changes externally (e.g. resume).
    if (_ctrl.text != lobby.name && !_ctrl.value.composing.isValid) {
      _ctrl.text = lobby.name;
      _ctrl.selection = TextSelection.collapsed(offset: lobby.name.length);
    }

    return LobbyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr.yourName,
            style: const TextStyle(
              fontSize: 11, letterSpacing: 2,
              color: AppColors.goldDim, fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLength: 24,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: tr.namePlaceholder,
              counterText: '',
            ),
            style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo'),
            onChanged: (v) => ref.read(lobbyProvider.notifier).setName(v),
            onSubmitted: (_) => _onCreate(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BurgundyButton(
                  label: tr.createRoom,
                  onTap: lobby.loading ? null : _onCreate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BurgundyButton(
                  label: tr.joinRoom,
                  primary: false,
                  onTap: lobby.loading
                      ? null
                      : () => ref.read(lobbyProvider.notifier).goJoin(),
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

  Future<void> _onCreate() async {
    setState(() => _error = null);
    final err = await ref.read(lobbyProvider.notifier).onCreate();
    if (err != null && mounted) setState(() => _error = err);
  }
}

// Shared card container used by start/join/room panels.
class LobbyCard extends StatelessWidget {
  final Widget child;
  const LobbyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: AppGradients.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}
