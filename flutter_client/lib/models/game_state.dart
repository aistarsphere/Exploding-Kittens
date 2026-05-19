import 'card_model.dart';
import 'prompt_type.dart';

/// Helper: socket.io sometimes returns Map<dynamic, dynamic> for nested objects.
/// Converts any Map to Map<String, dynamic> safely.
Map<String, dynamic> _m(dynamic v) =>
    v == null ? <String, dynamic>{} : Map<String, dynamic>.from(v as Map);

class PlayerState {
  final String id;
  final String name;
  final bool alive;

  const PlayerState({required this.id, required this.name, required this.alive});

  factory PlayerState.fromJson(Map<String, dynamic> j) => PlayerState(
    id: j['id'] as String,
    name: j['name'] as String,
    alive: (j['alive'] as bool?) ?? true,
  );
}

class Pending {
  final String actorId;
  final String kind;
  final Map<String, dynamic> payload;
  final int expiresAt;
  final List<String> nopeChain;

  const Pending({
    required this.actorId,
    required this.kind,
    required this.payload,
    required this.expiresAt,
    required this.nopeChain,
  });

  factory Pending.fromJson(Map<String, dynamic> j) => Pending(
    actorId: j['actorId'] as String,
    kind: j['kind'] as String,
    payload: _m(j['payload']),
    expiresAt: (j['expiresAt'] as num).toInt(),
    nopeChain: (j['nopeChain'] as List<dynamic>).cast<String>(),
  );

  List<CardModel> get cards {
    final raw = payload['cards'];
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((c) => CardModel.fromJson(_m(c)))
        .toList();
  }
}

class Prompt {
  final PromptType type;
  final String forPlayerId;
  final Map<String, dynamic> options;

  const Prompt({required this.type, required this.forPlayerId, required this.options});

  factory Prompt.fromJson(Map<String, dynamic> j) => Prompt(
    type: PromptType.fromString(j['type'] as String),
    forPlayerId: j['forPlayerId'] as String,
    options: _m(j['options']),
  );
}

class LogEntry {
  final int ts;
  final String text;

  const LogEntry({required this.ts, required this.text});

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
    ts: (j['ts'] as num).toInt(),
    text: j['text'] as String,
  );
}

class PublicState {
  final String status;
  final List<PlayerState> players;
  final List<String> turnOrder;
  final int turnIdx;
  final int direction;
  final int remainingTurns;
  final Map<String, int> handCounts;
  final int deckCount;
  final CardModel? topDiscard;
  final Pending? pending;
  final Prompt? prompt;
  final List<LogEntry> log;
  final String? winnerId;
  final String currentPlayerId;

  const PublicState({
    required this.status,
    required this.players,
    required this.turnOrder,
    required this.turnIdx,
    required this.direction,
    required this.remainingTurns,
    required this.handCounts,
    required this.deckCount,
    this.topDiscard,
    this.pending,
    this.prompt,
    required this.log,
    this.winnerId,
    required this.currentPlayerId,
  });

  factory PublicState.fromJson(Map<String, dynamic> j) => PublicState(
    status: j['status'] as String,
    players: (j['players'] as List<dynamic>)
        .map((p) => PlayerState.fromJson(_m(p)))
        .toList(),
    turnOrder: (j['turnOrder'] as List<dynamic>).cast<String>(),
    turnIdx: (j['turnIdx'] as num).toInt(),
    direction: (j['direction'] as num).toInt(),
    remainingTurns: (j['remainingTurns'] as num).toInt(),
    handCounts: Map<String, int>.fromEntries(
      _m(j['handCounts']).entries.map(
        (e) => MapEntry(e.key, (e.value as num).toInt()),
      ),
    ),
    deckCount: (j['deckCount'] as num).toInt(),
    topDiscard: j['topDiscard'] != null
        ? CardModel.fromJson(_m(j['topDiscard']))
        : null,
    pending: j['pending'] != null
        ? Pending.fromJson(_m(j['pending']))
        : null,
    prompt: j['prompt'] != null
        ? Prompt.fromJson(_m(j['prompt']))
        : null,
    log: (j['log'] as List<dynamic>)
        .map((e) => LogEntry.fromJson(_m(e)))
        .toList(),
    winnerId: j['winnerId'] as String?,
    currentPlayerId: j['currentPlayerId'] as String,
  );
}
