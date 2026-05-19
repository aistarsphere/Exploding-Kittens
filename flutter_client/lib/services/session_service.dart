import 'package:shared_preferences/shared_preferences.dart';

class SessionData {
  final String code;
  final String playerId;
  final String name;

  const SessionData({required this.code, required this.playerId, required this.name});
}

class SessionService {
  static const _keyCode    = 'ek_room_code';
  static const _keyPid     = 'ek_player_id';
  static const _keyName    = 'ek_player_name';
  static const _keyLang    = 'ek_lang';
  static const _keyMuted   = 'ek_sound_muted';

  Future<void> saveSession(String code, String playerId, String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyCode, code);
    await p.setString(_keyPid, playerId);
    await p.setString(_keyName, name);
  }

  Future<SessionData?> loadSession() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_keyCode);
    final pid  = p.getString(_keyPid);
    final name = p.getString(_keyName);
    if (code == null || pid == null) return null;
    return SessionData(code: code, playerId: pid, name: name ?? '');
  }

  Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyCode);
    await p.remove(_keyPid);
    await p.remove(_keyName);
  }

  Future<void> saveLang(String lang) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLang, lang);
  }

  Future<String> loadLang() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyLang) ?? 'en';
  }

  Future<void> saveSoundMuted(bool muted) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyMuted, muted);
  }

  Future<bool> loadSoundMuted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyMuted) ?? false;
  }
}
