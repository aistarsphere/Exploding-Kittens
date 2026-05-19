import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../providers/lobby_provider.dart';
import '../../providers/socket_provider.dart'; // socketServiceProvider
import '../../theme/app_theme.dart';
import '../../widgets/common/language_toggle.dart';
import '../../widgets/common/sound_toggle.dart';
import '../../router.dart';
import 'join_panel.dart';
import 'room_panel.dart';
import 'start_panel.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  StreamSubscription<void>? _startedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final socket = ref.read(socketServiceProvider);

    _startedSub = socket.lobbyStartedStream.listen((_) {
      if (mounted) _goToGame();
    });

    await ref.read(lobbyProvider.notifier).tryResume();

    // If resuming mid-game, lobby:update arrives before the ack so
    // lobby.started is already true by here — navigate directly.
    if (mounted) {
      final lobby = ref.read(lobbyProvider);
      if (lobby.lobby?.started == true && lobby.myPlayerId != null) {
        _goToGame();
      }
    }
  }

  void _goToGame() {
    final lobby = ref.read(lobbyProvider);
    if (lobby.myRoomCode == null || lobby.myPlayerId == null) return;
    context.go('/game', extra: GameRouteExtra(
      roomCode: lobby.myRoomCode!,
      playerId: lobby.myPlayerId!,
    ));
  }

  @override
  void dispose() {
    _startedSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final lobby = ref.watch(lobbyProvider);

    return Scaffold(
      body: Container(
        decoration: AppGradients.pageBackground,
        child: SafeArea(
          child: Stack(
            children: [
              // Top toolbar
              Positioned(
                top: 8, right: 12, left: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SoundToggle(),
                    const LanguageToggle(),
                  ],
                ),
              ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo.jpeg',
                          width: 260,
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),

                        // Panel switcher
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.06),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                          child: _buildPanel(lobby.step),
                        ),

                        // Connection lost banner
                        if (!lobby.connected) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.errorRed.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off, color: AppColors.errorRed, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  tr.connecting,
                                  style: const TextStyle(
                                    color: AppColors.errorRed,
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(LobbyStep step) {
    return switch (step) {
      LobbyStep.start => const StartPanel(key: ValueKey('start')),
      LobbyStep.join  => const JoinPanel(key: ValueKey('join')),
      LobbyStep.lobby => const RoomPanel(key: ValueKey('room')),
    };
  }
}
