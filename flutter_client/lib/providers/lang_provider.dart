import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/session_service.dart';

final _sessionService = SessionService();

class LangNotifier extends StateNotifier<String> {
  LangNotifier() : super('en') {
    _load();
  }

  Future<void> _load() async {
    final lang = await _sessionService.loadLang();
    state = lang;
  }

  void setLang(String lang) {
    state = lang;
    _sessionService.saveLang(lang);
  }

  void toggle() => setLang(state == 'en' ? 'ar' : 'en');
}

final langProvider = StateNotifierProvider<LangNotifier, String>(
  (_) => LangNotifier(),
);
