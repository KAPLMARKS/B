import 'dart:developer' as developer;

/// Centralised logger that masks sensitive data (API keys, tokens).
class AppLogger {
  static const String _tag = 'MealPlanner';

  static void info(String message, {String? source}) {
    final prefix = source != null ? '[$source]' : '';
    developer.log('$prefix $message', name: _tag, level: 800);
  }

  static void warning(String message, {String? source}) {
    final prefix = source != null ? '[$source]' : '';
    developer.log('WARN $prefix $message', name: _tag, level: 900);
  }

  static void error(String message, {String? source, Object? error, StackTrace? stackTrace}) {
    final prefix = source != null ? '[$source]' : '';
    developer.log(
      'ERROR $prefix $message',
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Masks API key for safe logging: "gsk_abc...xyz" -> "gsk_***xyz"
  static String maskKey(String? key) {
    if (key == null || key.length < 8) return '***';
    return '${key.substring(0, 4)}***${key.substring(key.length - 3)}';
  }
}
