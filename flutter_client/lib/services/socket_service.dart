import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/lobby_state.dart';
import '../models/game_state.dart';
import '../models/card_model.dart';

class SocketService {
  final String serverUrl;
  final String socketPath;
  late final io.Socket _socket;

  final _connController   = StreamController<bool>.broadcast();
  final _lobbyUpdController  = StreamController<LobbyState>.broadcast();
  final _lobbyStartedCtrl    = StreamController<void>.broadcast();
  final _gameStateCtrl       = StreamController<PublicState>.broadcast();
  final _gameHandCtrl        = StreamController<List<CardModel>>.broadcast();
  final _errorMsgCtrl        = StreamController<String>.broadcast();
  final _reconnectCtrl       = StreamController<void>.broadcast();

  Stream<bool>          get connectionStream   => _connController.stream;
  Stream<LobbyState>    get lobbyUpdateStream  => _lobbyUpdController.stream;
  Stream<void>          get lobbyStartedStream => _lobbyStartedCtrl.stream;
  Stream<PublicState>   get gameStateStream    => _gameStateCtrl.stream;
  Stream<List<CardModel>> get gameHandStream   => _gameHandCtrl.stream;
  Stream<String>        get errorMsgStream     => _errorMsgCtrl.stream;
  Stream<void>          get reconnectStream    => _reconnectCtrl.stream;

  bool _connected = false;
  bool get connected => _connected;

  SocketService(this.serverUrl, {this.socketPath = '/socket.io'}) {
    _socket = io.io(serverUrl, io.OptionBuilder()
      .setTransports(['websocket', 'polling'])
      .setPath(socketPath)
      .enableAutoConnect()
      .build());

    _socket.onConnect((_) {
      _connected = true;
      _connController.add(true);
      _reconnectCtrl.add(null);
    });

    _socket.onDisconnect((_) {
      _connected = false;
      _connController.add(false);
    });

    _socket.on('lobby:update', (data) {
      try {
        _lobbyUpdController.add(LobbyState.fromJson(Map<String, dynamic>.from(data as Map)));
      } catch (_) {}
    });

    _socket.on('lobby:started', (_) => _lobbyStartedCtrl.add(null));

    _socket.on('game:state', (data) {
      try {
        _gameStateCtrl.add(PublicState.fromJson(Map<String, dynamic>.from(data as Map)));
      } catch (_) {}
    });

    _socket.on('game:hand', (data) {
      try {
        final map = Map<String, dynamic>.from(data as Map);
        final hand = (map['hand'] as List<dynamic>)
            .map((c) => CardModel.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList();
        _gameHandCtrl.add(hand);
      } catch (_) {}
    });

    _socket.on('error:msg', (data) {
      try {
        final msg = (data as Map)['message'] as String? ?? 'Error';
        _errorMsgCtrl.add(msg);
      } catch (_) {}
    });
  }

  Future<Map<String, dynamic>> _emitAck(String event, dynamic data) async {
    final completer = Completer<Map<String, dynamic>>();
    _socket.emitWithAck(event, data, ack: (response) {
      try {
        if (response == null) {
          completer.complete({'ok': false, 'error': 'No response'});
        } else {
          completer.complete(Map<String, dynamic>.from(response as Map));
        }
      } catch (e) {
        completer.complete({'ok': false, 'error': e.toString()});
      }
    });
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => {'ok': false, 'error': 'Timeout'},
    );
  }

  Future<Map<String, dynamic>> lobbyCreate(String name) =>
      _emitAck('lobby:create', {'name': name});

  Future<Map<String, dynamic>> lobbyJoin(String code, String name) =>
      _emitAck('lobby:join', {'code': code, 'name': name});

  Future<Map<String, dynamic>> lobbyResume(String code, String playerId) =>
      _emitAck('lobby:resume', {'code': code, 'playerId': playerId});

  Future<Map<String, dynamic>> lobbyStart() =>
      _emitAck('lobby:start', {});

  Future<Map<String, dynamic>> lobbyLeave() =>
      _emitAck('lobby:leave', {});

  Future<Map<String, dynamic>> gamePlay(List<String> cardIds, [Map<String, dynamic>? payload]) =>
      _emitAck('game:play', {'cardIds': cardIds, 'payload': payload ?? {}});

  Future<Map<String, dynamic>> gameDraw() =>
      _emitAck('game:draw', {});

  void gameNope() => _socket.emit('game:nope', {});

  void gamePrompt(Map<String, dynamic> response) =>
      _socket.emit('game:prompt', {'response': response});

  void dispose() {
    _socket.dispose();
    _connController.close();
    _lobbyUpdController.close();
    _lobbyStartedCtrl.close();
    _gameStateCtrl.close();
    _gameHandCtrl.close();
    _errorMsgCtrl.close();
    _reconnectCtrl.close();
  }
}
