import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';
import '../services/sound_service.dart';

final _sessionService = SessionService();

final soundServiceProvider = Provider<SoundService>((ref) {
  final svc = SoundService();
  ref.onDispose(svc.dispose);
  return svc;
});

class SoundNotifier extends StateNotifier<bool> {
  final SoundService _svc;
  SoundNotifier(this._svc) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final muted = await _sessionService.loadSoundMuted();
    state = muted;
    _svc.muted = muted;
  }

  void toggle() {
    state = !state;
    _svc.muted = state;
    _sessionService.saveSoundMuted(state);
  }
}

final soundMutedProvider = StateNotifierProvider<SoundNotifier, bool>(
  (ref) => SoundNotifier(ref.watch(soundServiceProvider)),
);
