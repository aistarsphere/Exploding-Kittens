import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Lightweight wrapper around audioplayers for short SFX.
/// Mirrors the SFXKind list in /lib/sfx.ts on the server.
enum Sfx {
  tap, swoosh, draw, shuffle, nope, boom, defuse,
  snatch, sparkle, reverse, tick, fanfare, fail,
}

const Map<Sfx, String> _file = {
  Sfx.tap:     'sounds/tap.mp3',
  Sfx.swoosh:  'sounds/swoosh.mp3',
  Sfx.draw:    'sounds/draw.mp3',
  Sfx.shuffle: 'sounds/shuffle.mp3',
  Sfx.nope:    'sounds/nope.mp3',
  Sfx.boom:    'sounds/boom.mp3',
  Sfx.defuse:  'sounds/defuse.mp3',
  Sfx.snatch:  'sounds/snatch.mp3',
  Sfx.sparkle: 'sounds/sparkle.mp3',
  Sfx.reverse: 'sounds/reverse.mp3',
  Sfx.tick:    'sounds/tick.mp3',
  Sfx.fanfare: 'sounds/fanfare.mp3',
  Sfx.fail:    'sounds/fail.mp3',
};

class SoundService {
  bool _muted = false;
  final List<AudioPlayer> _pool = [];
  int _next = 0;

  SoundService() {
    // Pool of 4 players lets us overlap a few sounds without stuttering.
    for (var i = 0; i < 4; i++) {
      _pool.add(AudioPlayer()..setReleaseMode(ReleaseMode.stop));
    }
  }

  set muted(bool v) => _muted = v;
  bool get muted => _muted;

  Future<void> play(Sfx kind) async {
    if (_muted) return;
    final path = _file[kind];
    if (path == null) return;
    try {
      final p = _pool[_next % _pool.length];
      _next++;
      await p.stop();
      await p.play(AssetSource(path), volume: 0.6);
    } catch (e) {
      if (kDebugMode) debugPrint('SFX $kind failed: $e');
    }
  }

  Future<void> dispose() async {
    for (final p in _pool) {
      await p.dispose();
    }
  }
}
