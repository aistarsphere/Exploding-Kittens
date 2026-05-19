import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/lobby/lobby_screen.dart';
import 'screens/game/game_screen.dart';

class GameRouteExtra {
  final String roomCode;
  final String playerId;
  const GameRouteExtra({required this.roomCode, required this.playerId});

  Map<String, dynamic> toJson() => {'roomCode': roomCode, 'playerId': playerId};

  factory GameRouteExtra.fromJson(Map<String, dynamic> json) => GameRouteExtra(
    roomCode: json['roomCode'] as String,
    playerId: json['playerId'] as String,
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const LobbyScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (ctx, state) {
        final extra = state.extra as GameRouteExtra?;
        if (extra == null) return const LobbyScreen();
        return GameScreen(roomCode: extra.roomCode, playerId: extra.playerId);
      },
    ),
  ],
  errorBuilder: (ctx, state) => const Scaffold(
    body: Center(child: Text('Page not found', style: TextStyle(color: Colors.white))),
  ),
);
