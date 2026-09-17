// ignore_for_file: unused_field, unused_element, unused_element_parameter

/// Environment configuration for the application.
///
/// Controls Firebase project targeting and feature flags per environment.
enum Environment {
  development,
  staging,
  production,
}

/// Centralized environment configuration.
///
/// Each environment points to a different Firebase project to prevent
/// accidental writes to production during development.
class EnvironmentConfig {
  final Environment environment;
  final bool useFirebaseEmulators;
  final String firestoreEmulatorHost;
  final int firestoreEmulatorPort;
  final String authEmulatorHost;
  final int authEmulatorPort;
  final String storageEmulatorHost;
  final int storageEmulatorPort;
  final bool enableLogging;
  final LogLevel minimumLogLevel;

  const EnvironmentConfig._({
    required this.environment,
    this.useFirebaseEmulators = false,
    this.firestoreEmulatorHost = 'localhost',
    this.firestoreEmulatorPort = 8080,
    this.authEmulatorHost = 'localhost',
    this.authEmulatorPort = 9099,
    this.storageEmulatorHost = 'localhost',
    this.storageEmulatorPort = 9199,
    this.enableLogging = true,
    this.minimumLogLevel = LogLevel.debug,
  });

  /// Development — uses Firebase emulators, verbose logging.
  static const development = EnvironmentConfig._(
    environment: Environment.development,
    useFirebaseEmulators: true,
    enableLogging: true,
    minimumLogLevel: LogLevel.debug,
  );

  /// Staging — real Firebase project, moderate logging.
  static const staging = EnvironmentConfig._(
    environment: Environment.staging,
    useFirebaseEmulators: false,
    enableLogging: true,
    minimumLogLevel: LogLevel.info,
  );

  /// Production — real Firebase project, minimal logging.
  static const production = EnvironmentConfig._(
    environment: Environment.production,
    useFirebaseEmulators: false,
    enableLogging: true,
    minimumLogLevel: LogLevel.warning,
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}

/// Log levels for the application.
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}
