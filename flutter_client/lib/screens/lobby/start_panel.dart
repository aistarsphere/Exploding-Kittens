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

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final lobby = ref.watch(lobbyProvider);

    return _LobbyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr.yourName, style: const TextStyle(fontSize: 11, letterSpacing: 2, color: AppColors.goldDim, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          TextField(
            autofocus: true,
            maxLength: 24,
            decoration: InputDecoration(
              hintText: tr.namePlaceholder,
              counterText: '',
            ),
            style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo'),
            onChanged: (v) => ref.read(lobbyProvider.notifier).setName(v),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: BurgundyButton(
                label: tr.createRoom,
                onTap: lobby.loading ? null : () async {
                  final err = await ref.read(lobbyProvider.notifier).onCreate();
                  if (err != null && mounted) setState(() => _error = err);
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: BurgundyButton(
                label: tr.joinRoom,
                primary: false,
                onTap: () => ref.read(lobbyProvider.notifier).goJoin(),
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

class _LobbyCard extends StatelessWidget {
  final Widget child;
  const _LobbyCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppGradients.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.gold.withOpacity(0.15)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30)],
    ),
    child: child,
  );
}

// Export so other panels can reuse
class LobbyCard extends StatelessWidget {
  final Widget child;
  const LobbyCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppGradients.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.gold.withOpacity(0.15)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30)],
    ),
    child: child,
  );
}
