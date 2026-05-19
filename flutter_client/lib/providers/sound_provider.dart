import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';

final _sessionService = SessionService();

class SoundNotifier extends StateNotifier<bool> {
  SoundNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await _sessionService.loadSoundMuted();
  }

  void toggle() {
    state = !state;
    _sessionService.saveSoundMuted(state);
  }
}

final soundMutedProvider = StateNotifierProvider<SoundNotifier, bool>(
  (_) => SoundNotifier(),
);
