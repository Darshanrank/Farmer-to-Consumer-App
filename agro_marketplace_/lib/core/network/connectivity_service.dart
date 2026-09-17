import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity service.
///
/// Critical for rural-area operation where network is unreliable.
/// Used to show appropriate UI and prevent operations that require network.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Checks if the device currently has network connectivity.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream of connectivity changes.
  Stream<bool> get connectivityStream =>
      _connectivity.onConnectivityChanged.map(
        (results) => results.any((r) => r != ConnectivityResult.none),
      );
}
