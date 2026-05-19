import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lobby_state.dart';
import '../services/session_service.dart';
import '../services/socket_service.dart';
import 'socket_provider.dart';

enum LobbyStep { start, join, lobby }

class LobbyUiState {
  final LobbyStep step;
  final String name;
  final String code;
  final String? myPlayerId;
  final String? myRoomCode;
  final LobbyState? lobby;
  final String? error;
  final bool connected;
  final bool loading;

  const LobbyUiState({
    this.step = LobbyStep.start,
    this.name = '',
    this.code = '',
    this.myPlayerId,
    this.myRoomCode,
    this.lobby,
    this.error,
    this.connected = false,
    this.loading = false,
  });

  LobbyUiState copyWith({
    LobbyStep? step,
    String? name,
    String? code,
    String? myPlayerId,
    String? myRoomCode,
    LobbyState? lobby,
    String? error,
    bool? connected,
    bool? loading,
    bool clearError = false,
    bool clearLobby = false,
    bool clearPlayerInfo = false,
  }) => LobbyUiState(
    step: step ?? this.step,
    name: name ?? this.name,
    code: code ?? this.code,
    myPlayerId: clearPlayerInfo ? null : (myPlayerId ?? this.myPlayerId),
    myRoomCode: clearPlayerInfo ? null : (myRoomCode ?? this.myRoomCode),
    lobby: clearLobby ? null : (lobby ?? this.lobby),
    error: clearError ? null : (error ?? this.error),
    connected: connected ?? this.connected,
    loading: loading ?? this.loading,
  );
}

class LobbyNotifier extends StateNotifier<LobbyUiState> {
  final SocketService _socket;
  final SessionService _session = SessionService();
  final List<StreamSubscription> _subs = [];

  LobbyNotifier(this._socket) : super(const LobbyUiState()) {
    _subs.add(_socket.connectionStream.listen((c) {
      state = state.copyWith(connected: c);
    }));
    state = state.copyWith(connected: _socket.connected);

    _subs.add(_socket.lobbyUpdateStream.listen((l) {
      state = state.copyWith(lobby: l);
    }));
  }

  void setName(String v) => state = state.copyWith(name: v, clearError: true);
  void setCode(String v) => state = state.copyWith(code: v.toUpperCase(), clearError: true);
  void goJoin() => state = state.copyWith(step: LobbyStep.join, clearError: true);
  void goStart() => state = state.copyWith(step: LobbyStep.start, clearError: true);

  Future<String?> onCreate() async {
    if (state.name.trim().isEmpty) return 'Please enter your name.';
    state = state.copyWith(loading: true, clearError: true);
    final res = await _socket.lobbyCreate(state.name.trim());
    state = state.copyWith(loading: false);
    if (res['ok'] != true) return res['error'] as String? ?? 'Failed.';
    final code = res['code'] as String;
    final pid  = res['playerId'] as String;
    await _session.saveSession(code, pid, state.name.trim());
    state = state.copyWith(
      myPlayerId: pid,
      myRoomCode: code,
      step: LobbyStep.lobby,
    );
    return null;
  }

  Future<String?> onJoinGo() async {
    if (state.name.trim().isEmpty) return 'Please enter your name.';
    if (state.code.trim().isEmpty) return 'Enter a room code.';
    state = state.copyWith(loading: true, clearError: true);
    final res = await _socket.lobbyJoin(state.code.trim(), state.name.trim());
    state = state.copyWith(loading: false);
    if (res['ok'] != true) return res['error'] as String? ?? 'Failed.';
    final code = res['code'] as String;
    final pid  = res['playerId'] as String;
    await _session.saveSession(code, pid, state.name.trim());
    state = state.copyWith(
      myPlayerId: pid,
      myRoomCode: code,
      step: LobbyStep.lobby,
    );
    return null;
  }

  Future<String?> onStart() async {
    final res = await _socket.lobbyStart();
    if (res['ok'] != true) return res['error'] as String? ?? 'Failed to start.';
    return null;
  }

  Future<void> onLeave() async {
    await _socket.lobbyLeave();
    await _session.clearSession();
    state = const LobbyUiState();
  }

  Future<bool> tryResume() async {
    final saved = await _session.loadSession();
    if (saved == null) return false;
    state = state.copyWith(name: saved.name);
    final res = await _socket.lobbyResume(saved.code, saved.playerId);
    if (res['ok'] != true) return false;
    state = state.copyWith(
      myPlayerId: saved.playerId,
      myRoomCode: saved.code,
      step: LobbyStep.lobby,
    );
    return true;
  }

  @override
  void dispose() {
    for (final s in _subs) s.cancel();
    super.dispose();
  }
}

final lobbyProvider = StateNotifierProvider<LobbyNotifier, LobbyUiState>((ref) {
  final socket = ref.watch(socketServiceProvider);
  return LobbyNotifier(socket);
});
