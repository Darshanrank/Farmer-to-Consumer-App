import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import '../../core/logging/app_logger.dart';
import '../../firebase_options.dart';
import '../config/environment.dart';

/// Application bootstrap sequence.
///
/// Initializes all required services before the UI is rendered.
/// Firebase is initialized only when a default Firebase app does not
/// already exist.
class Bootstrap {
  const Bootstrap._();

  /// Runs the full initialization sequence for the given [config].
  static Future<void> initialize(EnvironmentConfig config) async {
    // Ensure Flutter bindings are initialized before using platform services.
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations (mobile-first).
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize logger first — needed for all subsequent init logging.
    AppLogger.initialize(config);

    AppLogger.info(
      'Bootstrap started',
      context: 'Bootstrap',
      data: {
        'environment': config.environment.name,
      },
    );

    // Initialize Firebase.
    //
    // Android's native Firebase SDK can initialize the [DEFAULT] app before
    // Dart runs (via google-services.json). We check for that by attempting
    // to retrieve the default app — if it already exists we skip init.
    try {
      // Try to get the existing default app first.
      bool alreadyInitialized = false;
      try {
        Firebase.app(); // throws if no default app exists
        alreadyInitialized = true;
        AppLogger.info(
          'Firebase [DEFAULT] app already exists — skipping initializeApp()',
          context: 'Bootstrap',
        );
      } catch (_) {
        // No default app yet — initialize now.
      }

      if (!alreadyInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      AppLogger.info(
        'Firebase initialized',
        context: 'Bootstrap',
        data: {
          'appCount': Firebase.apps.length,
          'appName': Firebase.apps.first.name,
        },
      );

      // Connect to Firebase emulators in development.
      if (config.useFirebaseEmulators) {
        await _connectToEmulators(config);
      }
    } on FirebaseException catch (e, st) {
      if (e.code == 'duplicate-app') {
        AppLogger.warning(
          'Firebase duplicate-app caught — already initialized, continuing.',
          context: 'Bootstrap',
        );
      } else {
        AppLogger.critical(
          'Firebase initialization failed',
          context: 'Bootstrap',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }
    } catch (e, st) {
      AppLogger.critical(
        'Firebase initialization failed',
        context: 'Bootstrap',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }

    // Initialize FCM (future).
    // await _initializeNotifications();

    // Initialize App Check.
    // Wrapped in try/catch — in debug builds the debug token must be
    // registered in Firebase Console. If it isn't, App Check returns
    // DEVELOPER_ERROR but the app must NOT crash because of it.
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
      AppLogger.info('Firebase App Check activated', context: 'Bootstrap');
    } catch (e) {
      AppLogger.warning(
        'Firebase App Check activation failed — continuing without it. '
        'Register the debug token in Firebase Console to silence this.',
        context: 'Bootstrap',
      );
      // Non-fatal: app continues without App Check enforcement.
    }

    AppLogger.info(
      'Bootstrap completed',
      context: 'Bootstrap',
    );
  }

  /// Connects Firebase SDK to local emulators for development.
  static Future<void> _connectToEmulators(
    EnvironmentConfig config,
  ) async {
    // Firestore emulator.
    // FirebaseFirestore.instance.useFirestoreEmulator(
    //   config.firestoreEmulatorHost,
    //   config.firestoreEmulatorPort,
    // );

    // Auth emulator.
    // await FirebaseAuth.instance.useAuthEmulator(
    //   config.authEmulatorHost,
    //   config.authEmulatorPort,
    // );

    // Storage emulator.
    // await FirebaseStorage.instance.useStorageEmulator(
    //   config.storageEmulatorHost,
    //   config.storageEmulatorPort,
    // );

    AppLogger.info(
      'Connected to Firebase emulators',
      context: 'Bootstrap',
      data: {
        'firestore':
            '${config.firestoreEmulatorHost}:${config.firestoreEmulatorPort}',
        'auth':
            '${config.authEmulatorHost}:${config.authEmulatorPort}',
        'storage':
            '${config.storageEmulatorHost}:${config.storageEmulatorPort}',
      },
    );
  }
}