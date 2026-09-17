import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap/bootstrap.dart';
import 'app/config/environment.dart';

/// Production entry point.
///
/// Uses real Firebase project with production logging levels.
void main() async {
  await Bootstrap.initialize(EnvironmentConfig.production);

  runApp(
    const ProviderScope(
      child: AgroMarketApp(),
    ),
  );
}
