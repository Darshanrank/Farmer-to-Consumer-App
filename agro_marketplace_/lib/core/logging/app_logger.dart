import 'dart:developer' as developer;
import 'package:logger/logger.dart' as log_pkg;

import '../../app/config/environment.dart';

/// Structured application logger.
///
/// Provides consistent, structured logging with context across the app.
/// Automatically respects environment-based log level filtering.
///
/// Usage:
/// ```dart
/// AppLogger.info('Seller profile created', context: 'SellerRepository', data: {'sellerId': id});
/// AppLogger.error('Failed to create order', error: e, stackTrace: st, context: 'OrderService');
/// ```
///
/// NEVER log:
/// - Passwords, tokens, OTPs
/// - Payment secrets
/// - Sensitive personal documents
/// - Firebase auth tokens
class AppLogger {
  static late final log_pkg.Logger _logger;
  static late final LogLevel _minimumLevel;
  static bool _initialized = false;

  /// Initialize the logger with environment configuration.
  static void initialize(EnvironmentConfig config) {
    _minimumLevel = config.minimumLogLevel;
    _logger = log_pkg.Logger(
      printer: log_pkg.PrettyPrinter(
        methodCount: config.isDevelopment ? 2 : 0,
        errorMethodCount: 5,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        dateTimeFormat: log_pkg.DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: _mapLogLevel(config.minimumLogLevel),
    );
    _initialized = true;
  }

  /// Debug-level log. Only in development.
  static void debug(
    String message, {
    String? context,
    Map<String, dynamic>? data,
  }) {
    if (!_shouldLog(LogLevel.debug)) return;
    final formatted = _format(message, context: context, data: data);
    _logger.d(formatted);
    _devLog(message, level: 500, context: context);
  }

  /// Info-level log. Significant events (login, order created, etc.).
  static void info(
    String message, {
    String? context,
    Map<String, dynamic>? data,
  }) {
    if (!_shouldLog(LogLevel.info)) return;
    final formatted = _format(message, context: context, data: data);
    _logger.i(formatted);
    _devLog(message, level: 800, context: context);
  }

  /// Warning-level log. Potential issues, degraded performance.
  static void warning(
    String message, {
    String? context,
    Map<String, dynamic>? data,
    dynamic error,
  }) {
    if (!_shouldLog(LogLevel.warning)) return;
    final formatted = _format(message, context: context, data: data);
    _logger.w(formatted, error: error);
    _devLog(message, level: 900, context: context);
  }

  /// Error-level log. Operation failures, caught exceptions.
  static void error(
    String message, {
    String? context,
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(LogLevel.error)) return;
    final formatted = _format(message, context: context, data: data);
    _logger.e(formatted, error: error, stackTrace: stackTrace);
    _devLog(message, level: 1000, context: context);
  }

  /// Critical-level log. System-level failures requiring immediate attention.
  static void critical(
    String message, {
    String? context,
    Map<String, dynamic>? data,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // Critical always logs.
    final formatted = _format(message, context: context, data: data);
    _logger.f(formatted, error: error, stackTrace: stackTrace);
    _devLog(message, level: 1200, context: context);
  }

  // --- Private helpers ---

  static bool _shouldLog(LogLevel level) {
    if (!_initialized) return true; // Before init, log everything
    return level.index >= _minimumLevel.index;
  }

  static String _format(
    String message, {
    String? context,
    Map<String, dynamic>? data,
  }) {
    final buffer = StringBuffer();
    if (context != null) buffer.write('[$context] ');
    buffer.write(message);
    if (data != null && data.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(data.entries.map((e) => '${e.key}=${e.value}').join(', '));
    }
    return buffer.toString();
  }

  static void _devLog(String message, {required int level, String? context}) {
    developer.log(
      message,
      level: level,
      name: context ?? 'AgroMarket',
    );
  }

  static log_pkg.Level _mapLogLevel(LogLevel level) => switch (level) {
    LogLevel.debug => log_pkg.Level.debug,
    LogLevel.info => log_pkg.Level.info,
    LogLevel.warning => log_pkg.Level.warning,
    LogLevel.error => log_pkg.Level.error,
    LogLevel.critical => log_pkg.Level.fatal,
  };
}
