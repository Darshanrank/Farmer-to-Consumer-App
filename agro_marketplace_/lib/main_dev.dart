import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/bootstrap.dart';
import 'app/config/environment.dart';

/// Development entry point.
///
/// Uses Firebase emulators and verbose logging.
/// Run with: flutter run -t lib/main_dev.dart
void main() async {
  await Bootstrap.initialize(EnvironmentConfig.development);

  runApp(
    const ProviderScope(
      child: AgroMarketApp(),
    ),
  );
}
