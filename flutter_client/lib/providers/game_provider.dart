import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';
import '../services/socket_service.dart';
import '../services/session_service.dart';
import 'socket_provider.dart';

class GameUiState {
  final PublicState? state;
  final List<CardModel> hand;
  final Set<String> selectedIds;
  final String? toast;
  final bool turnFlash;
  final List<String>? favorPickCardIds;

  const GameUiState({
    this.state,
    this.hand = const [],
    this.selectedIds = const {},
    this.toast,
    this.turnFlash = false,
    this.favorPickCardIds,
  });

  GameUiState copyWith({
    PublicState? state,
    List<CardModel>? hand,
    Set<String>? selectedIds,
    String? toast,
    bool? turnFlash,
    List<String>? favorPickCardIds,
    bool clearToast = false,
    bool clearFavorPick = false,
  }) => GameUiState(
    state: state ?? this.state,
    hand: hand ?? this.hand,
    selectedIds: selectedIds ?? this.selectedIds,
    toast: clearToast ? null : (toast ?? this.toast),
    turnFlash: turnFlash ?? this.turnFlash,
    favorPickCardIds: clearFavorPick ? null : (favorPickCardIds ?? this.favorPickCardIds),
  );
}

class GameNotifier extends StateNotifier<GameUiState> {
  final SocketService _socket;
  final SessionService _session = SessionService();
  final String myPlayerId;
  final List<StreamSubscription> _subs = [];

  GameNotifier(this._socket, this.myPlayerId) : super(const GameUiState()) {
    _subs.add(_socket.gameStateStream.listen(_onState));
    _subs.add(_socket.gameHandStream.listen(_onHand));
    _subs.add(_socket.errorMsgStream.listen(_onError));
  }

  /// Called once after GameScreen's first frame — asks the server to resend
  /// game:state + game:hand, which may have arrived before this notifier
  /// existed (broadcast streams drop events with no listener).
  Future<void> requestState(String code) async {
    await _socket.lobbyResume(code, myPlayerId);
  }

  void _onState(PublicState s) {
    final prev = state.state;
    // Detect turn transition to me
    bool flash = false;
    if (prev != null &&
        prev.currentPlayerId != s.currentPlayerId &&
        s.currentPlayerId == myPlayerId &&
        s.status == 'playing') {
      flash = true;
    }
    state = state.copyWith(state: s, turnFlash: flash);
    if (flash) {
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) state = state.copyWith(turnFlash: false);
      });
    }
  }

  void _onHand(List<CardModel> hand) {
    final ids = hand.map((c) => c.id).toSet();
    final filtered = state.selectedIds.intersection(ids);
    state = state.copyWith(hand: hand, selectedIds: filtered);
  }

  void _onError(String msg) {
    state = state.copyWith(toast: msg);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) state = state.copyWith(clearToast: true);
    });
  }

  void toggleCard(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  Future<void> playSelected() async {
    if (state.selectedIds.isEmpty) return;
    final ids = state.selectedIds.toList();
    final cards = ids
        .map((id) => state.hand.firstWhere((c) => c.id == id, orElse: () => CardModel(id: id, type: CardType.NOPE)))
        .toList();

    if (cards.length == 1 && cards[0].type == CardType.FAVOR) {
      state = state.copyWith(favorPickCardIds: ids);
      return;
    }
    await _sendPlay(ids, {});
  }

  Future<void> sendPlayWithTarget(List<String> cardIds, Map<String, dynamic> payload) async {
    state = state.copyWith(clearFavorPick: true);
    await _sendPlay(cardIds, payload);
  }

  void cancelFavorPick() => state = state.copyWith(clearFavorPick: true);

  Future<void> _sendPlay(List<String> cardIds, Map<String, dynamic> payload) async {
    final res = await _socket.gamePlay(cardIds, payload);
    if (res['ok'] != true) {
      _onError(res['error'] as String? ?? 'Cannot play.');
    } else {
      state = state.copyWith(selectedIds: {});
    }
  }

  Future<void> onDraw() async {
    final res = await _socket.gameDraw();
    if (res['ok'] != true) {
      _onError(res['error'] as String? ?? 'Cannot draw.');
    }
  }

  void onNope() => _socket.gameNope();

  void onPrompt(Map<String, dynamic> response) => _socket.gamePrompt(response);

  Future<void> onLeave() async {
    await _socket.lobbyLeave();
    await _session.clearSession();
  }

  bool get isMyTurn => state.state?.currentPlayerId == myPlayerId;
  bool get canAct => isMyTurn &&
      state.state?.status == 'playing' &&
      state.state?.pending == null &&
      state.state?.prompt == null;

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    super.dispose();
  }
}

final gameProvider = StateNotifierProvider.autoDispose
    .family<GameNotifier, GameUiState, String>(
  (ref, playerId) {
    final socket = ref.watch(socketServiceProvider);
    return GameNotifier(socket, playerId);
  },
);
