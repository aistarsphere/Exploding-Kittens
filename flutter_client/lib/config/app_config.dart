class AppConfig {
  static const String _defaultServerUrl = 'http://52.58.22.19/kittens';

  static const String serverUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: _defaultServerUrl,
  );

  static String cardImageUrl(String filename) => '$serverUrl/images/$filename';
}
