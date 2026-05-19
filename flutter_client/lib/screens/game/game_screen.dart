import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/game_provider.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/game/game_log.dart';
import '../../widgets/game/hand_section.dart';
import '../../widgets/game/juice_layer.dart';
import '../../widgets/game/nope_banner.dart';
import '../../widgets/game/opponents_row.dart';
import '../../widgets/game/table_section.dart';
import '../../widgets/game/top_bar.dart';
import '../../widgets/game/turn_flash.dart';
import '../../widgets/prompts/game_over_overlay.dart';
import '../../widgets/prompts/pick_target_overlay.dart';
import '../../widgets/prompts/prompt_router.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String roomCode;
  final String playerId;

  const GameScreen({super.key, required this.roomCode, required this.playerId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  final GlobalKey<JuiceLayerState> _juiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // After first frame: GameNotifier is subscribed — ask server to resend
    // game:state + game:hand (they arrive before this screen exists).
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestState());
  }

  Future<void> _requestState() async {
    if (!mounted) return;
    await ref.read(gameProvider(widget.playerId).notifier)
        .requestState(widget.roomCode);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _requestState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _onLeave() {
    ref.read(gameProvider(widget.playerId).notifier).onLeave();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider(widget.playerId));
    final notifier = ref.read(gameProvider(widget.playerId).notifier);
    final state = game.state;

    return Scaffold(
      body: Container(
        decoration: AppGradients.pageBackground,
        child: SafeArea(
          child: Stack(
            children: [
              // ── Main layout ──────────────────────────────────────────────
              Column(
                children: [
                  // Top bar
                  TopBar(
                    roomCode: widget.roomCode,
                    state: state,
                    myPlayerId: widget.playerId,
                    onLeave: _onLeave,
                  ),

                  // Disconnect banner
                  if (!game.connected) const _DisconnectBanner(),

                  if (state != null) ...[
                    // Opponents
                    OpponentsRow(state: state, myPlayerId: widget.playerId),

                    // Table (draw + discard)
                    TableSection(state: state),

                    // Nope banner (only visible when there's a pending action)
                    if (state.pending != null)
                      NopeBanner(
                        state: state,
                        myHand: game.hand,
                        myPlayerId: widget.playerId,
                        onNope: notifier.onNope,
                      ),

                    // Game log
                    Expanded(child: GameLog(log: state.log)),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 36, height: 36,
                              child: CircularProgressIndicator(
                                color: AppColors.gold,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(ref.watch(langProvider)).loading,
                              style: const TextStyle(
                                color: AppColors.goldDim,
                                fontFamily: 'Cairo',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Hand + action buttons
                  HandSection(
                    hand: game.hand,
                    selectedIds: game.selectedIds,
                    onToggle: notifier.toggleCard,
                    onPlaySelected: notifier.playSelected,
                    onDraw: notifier.onDraw,
                    canAct: notifier.canAct,
                    isMyTurn: notifier.isMyTurn,
                  ),
                ],
              ),

              // ── Overlays ─────────────────────────────────────────────────

              // Prompt modals
              if (state != null && state.prompt != null)
                PromptRouter(
                  state: state,
                  myPlayerId: widget.playerId,
                  onRespond: notifier.onPrompt,
                ),

              // Pick-target overlay for Favor card
              if (game.favorPickCardIds != null && state != null)
                PickTargetOverlay(
                  title: AppLocalizations.of(ref.read(langProvider)).favor,
                  state: state,
                  myPlayerId: widget.playerId,
                  onPick: (targetId) => notifier.sendPlayWithTarget(
                    game.favorPickCardIds!,
                    {'target': targetId}, // server reads payload.payload.target
                  ),
                  onCancel: notifier.cancelFavorPick,
                ),

              // Game over
              if (state != null && state.status == 'ended')
                GameOverOverlay(
                  state: state,
                  myPlayerId: widget.playerId,
                  onBackToLobby: _onLeave,
                ),

              // Turn flash
              TurnFlash(visible: game.turnFlash),

              // Toast
              if (game.toast != null)
                Positioned(
                  bottom: 120,
                  left: 32,
                  right: 32,
                  child: _Toast(message: game.toast!),
                ),

              // Juice layer (floating text animations)
              JuiceLayer(key: _juiceKey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisconnectBanner extends ConsumerWidget {
  const _DisconnectBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = AppLocalizations.of(ref.watch(langProvider));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.errorRed.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 10, height: 10,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.errorRed),
          ),
          const SizedBox(width: 8),
          Text(
            tr.connecting,
            style: const TextStyle(
              color: AppColors.errorRed,
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Toast extends StatefulWidget {
  final String message;
  const _Toast({required this.message});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDeep.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.errorRed.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16)],
      ),
      child: Text(
        widget.message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.errorRed,
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
