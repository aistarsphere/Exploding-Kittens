import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../providers/lobby_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/burgundy_button.dart';
import 'start_panel.dart';

class RoomPanel extends ConsumerStatefulWidget {
  const RoomPanel({super.key});

  @override
  ConsumerState<RoomPanel> createState() => _RoomPanelState();
}

class _RoomPanelState extends ConsumerState<RoomPanel> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final lobby = ref.watch(lobbyProvider);
    final isHost = lobby.lobby?.hostId == lobby.myPlayerId;
    final canStart = isHost && (lobby.lobby?.players.length ?? 0) >= 2;

    return LobbyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.goldLight),
              children: [
                TextSpan(text: '${tr.room} '),
                TextSpan(
                  text: lobby.myRoomCode ?? '',
                  style: const TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.w800,
                    letterSpacing: 6, fontFamily: 'Cairo', fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isHost ? tr.youAreMaster : tr.waitingForMaster,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.goldDim, fontFamily: 'Cairo', fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...(lobby.lobby?.players ?? []).map((p) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgDeep.withOpacity(0.7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.gold.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${p.name}${p.id == lobby.myPlayerId ? tr.you : ''}',
                    style: const TextStyle(color: AppColors.goldLight, fontFamily: 'Cairo'),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p.id == lobby.lobby?.hostId) _Badge(label: tr.master),
                    if (!p.connected) _Badge(label: tr.offline, dim: true),
                  ],
                ),
              ],
            ),
          )),
          const SizedBox(height: 14),
          Row(
            children: [
              if (canStart) ...[
                Expanded(child: BurgundyButton(
                  label: tr.startGame,
                  onTap: () async {
                    final err = await ref.read(lobbyProvider.notifier).onStart();
                    if (err != null && mounted) setState(() => _error = err);
                  },
                )),
                const SizedBox(width: 10),
              ],
              Expanded(child: BurgundyButton(
                label: tr.leave,
                primary: false,
                onTap: () => ref.read(lobbyProvider.notifier).onLeave(),
              )),
            ],
          ),
          const SizedBox(height: 10),
          Text(tr.shareHint, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.goldDim, fontSize: 11, fontFamily: 'Cairo', fontStyle: FontStyle.italic)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.errorRed, fontSize: 13, fontFamily: 'Cairo')),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool dim;
  const _Badge({required this.label, this.dim = false});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      gradient: dim ? null : AppGradients.primaryButton,
      color: dim ? const Color(0xFF2A1612) : null,
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: dim ? AppColors.gold.withOpacity(0.1) : AppColors.gold.withOpacity(0.4)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: dim ? AppColors.badgeOff : Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        fontFamily: 'Cairo',
      ),
    ),
  );
}
