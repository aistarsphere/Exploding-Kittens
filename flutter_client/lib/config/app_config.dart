class AppConfig {
  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://52.58.22.19/kittens',
  );

  // Host only (no path) — used as socket.io URI
  static String get socketHost {
    final uri = Uri.parse(serverUrl);
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  // Path prefix for socket.io handshake (e.g. /kittens/socket.io)
  static String get socketPath {
    final uri = Uri.parse(serverUrl);
    final base = uri.path.replaceAll(RegExp(r'/+$'), ''); // strip trailing slash
    return base.isEmpty ? '/socket.io' : '$base/socket.io';
  }

  static String cardImageUrl(String filename) => '$serverUrl/images/$filename';
}
