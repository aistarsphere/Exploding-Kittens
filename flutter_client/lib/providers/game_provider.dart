import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/card_types.dart' show isCat;
import '../models/game_state.dart';
import '../services/socket_service.dart';
import '../services/session_service.dart';
import '../services/sound_service.dart';
import 'socket_provider.dart';
import 'sound_provider.dart';

class GameUiState {
  final PublicState? state;
  final List<CardModel> hand;
  final Set<String> selectedIds;
  final String? toast;
  final bool turnFlash;
  final List<String>? favorPickCardIds;
  final bool connected;

  const GameUiState({
    this.state,
    this.hand = const [],
    this.selectedIds = const {},
    this.toast,
    this.turnFlash = false,
    this.favorPickCardIds,
    this.connected = true,
  });

  GameUiState copyWith({
    PublicState? state,
    List<CardModel>? hand,
    Set<String>? selectedIds,
    String? toast,
    bool? turnFlash,
    List<String>? favorPickCardIds,
    bool? connected,
    bool clearToast = false,
    bool clearFavorPick = false,
  }) => GameUiState(
    state: state ?? this.state,
    hand: hand ?? this.hand,
    selectedIds: selectedIds ?? this.selectedIds,
    toast: clearToast ? null : (toast ?? this.toast),
    turnFlash: turnFlash ?? this.turnFlash,
    favorPickCardIds: clearFavorPick ? null : (favorPickCardIds ?? this.favorPickCardIds),
    connected: connected ?? this.connected,
  );
}

class GameNotifier extends StateNotifier<GameUiState> {
  final SocketService _socket;
  final SoundService _sfx;
  final SessionService _session = SessionService();
  final String myPlayerId;
  final List<StreamSubscription> _subs = [];
  String? _roomCode;

  GameNotifier(this._socket, this._sfx, this.myPlayerId)
      : super(GameUiState(connected: _socket.connected)) {
    _subs.add(_socket.gameStateStream.listen(_onState));
    _subs.add(_socket.gameHandStream.listen(_onHand));
    _subs.add(_socket.errorMsgStream.listen(_onError));
    _subs.add(_socket.connectionStream.listen((c) {
      state = state.copyWith(connected: c);
      // On reconnect, re-bind to the room and ask for fresh state.
      if (c && _roomCode != null) {
        _socket.lobbyResume(_roomCode!, myPlayerId)
            .catchError((_) => <String, dynamic>{});
      }
    }));
  }

  /// Called once after GameScreen's first frame — asks the server to resend
  /// game:state + game:hand, which may have arrived before this notifier
  /// existed (broadcast streams drop events with no listener).
  Future<void> requestState(String code) async {
    _roomCode = code;
    await _socket.lobbyResume(code, myPlayerId);
  }

  void _onState(PublicState s) {
    final prev = state.state;
    _maybePlaySfx(prev, s);

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

  /// Diff prev → next state and play SFX for notable changes.
  void _maybePlaySfx(PublicState? prev, PublicState s) {
    // First state — game just started.
    if (prev == null) {
      _sfx.play(Sfx.shuffle);
      return;
    }

    // Top discard changed → some card was played (or drawn into discard).
    final prevTop = prev.topDiscard?.id;
    final curTop  = s.topDiscard?.id;
    if (curTop != null && curTop != prevTop) {
      final t = s.topDiscard!.type;
      switch (t) {
        case CardType.NOPE:             _sfx.play(Sfx.nope); break;
        case CardType.EXPLODING_KITTEN: _sfx.play(Sfx.boom); break;
        case CardType.DEFUSE:           _sfx.play(Sfx.defuse); break;
        case CardType.SKIP:
        case CardType.ATTACK:
        case CardType.DOUBLE_SLAP:
        case CardType.TRIPLE_SLAP:      _sfx.play(Sfx.swoosh); break;
        case CardType.SHUFFLE:          _sfx.play(Sfx.shuffle); break;
        case CardType.FAVOR:            _sfx.play(Sfx.snatch); break;
        case CardType.SEE_THE_FUTURE:
        case CardType.ALTER_THE_FUTURE: _sfx.play(Sfx.sparkle); break;
        case CardType.REVERSE:          _sfx.play(Sfx.reverse); break;
        case CardType.DRAW_FROM_BOTTOM: _sfx.play(Sfx.draw); break;
        default:
          if (isCat(t)) _sfx.play(Sfx.snatch);
      }
    }

    // Deck went down by 1 with no new discard → silent draw.
    if (s.deckCount < prev.deckCount && curTop == prevTop) {
      _sfx.play(Sfx.draw);
    }

    // Game ended.
    if (prev.status != 'ended' && s.status == 'ended') {
      _sfx.play(s.winnerId == myPlayerId ? Sfx.fanfare : Sfx.fail);
    }

    // Player died (lost an alive player).
    final prevAlive = prev.players.where((p) => p.alive).length;
    final curAlive = s.players.where((p) => p.alive).length;
    if (curAlive < prevAlive) _sfx.play(Sfx.boom);

  }

  void _onHand(List<CardModel> hand) {
    final ids = hand.map((c) => c.id).toSet();
    final filtered = state.selectedIds.intersection(ids);
    state = state.copyWith(hand: hand, selectedIds: filtered);
  }

  void _onError(String msg) {
    _sfx.play(Sfx.fail);
    state = state.copyWith(toast: msg);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) state = state.copyWith(clearToast: true);
    });
  }

  void toggleCard(String id) {
    _sfx.play(Sfx.tap);
    HapticFeedback.selectionClick();
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
    final sfx = ref.watch(soundServiceProvider);
    return GameNotifier(socket, sfx, playerId);
  },
);
