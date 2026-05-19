class LobbyPlayer {
  final String id;
  final String name;
  final bool connected;

  const LobbyPlayer({required this.id, required this.name, required this.connected});

  factory LobbyPlayer.fromJson(Map<String, dynamic> j) => LobbyPlayer(
    id: j['id'] as String,
    name: j['name'] as String,
    connected: (j['connected'] as bool?) ?? true,
  );
}

class LobbyState {
  final String code;
  final String? hostId;
  final bool started;
  final List<LobbyPlayer> players;

  const LobbyState({required this.code, this.hostId, required this.started, required this.players});

  factory LobbyState.fromJson(Map<String, dynamic> j) => LobbyState(
    code: j['code'] as String,
    hostId: j['hostId'] as String?,
    started: (j['started'] as bool?) ?? false,
    players: (j['players'] as List<dynamic>)
        .map((p) => LobbyPlayer.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList(),
  );
}
