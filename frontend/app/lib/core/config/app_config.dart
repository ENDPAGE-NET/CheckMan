class AppConfig {
  static const String appName = 'ENDPAGE';
  static const String apiBaseUrl = 'http://localhost:8000';

  static String get baseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: apiBaseUrl,
      );
}
