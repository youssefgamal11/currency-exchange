import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

abstract class ConnectivityService {
  Stream<bool> get onStatusChange;

  Future<bool> isConnected();
}

@LazySingleton(as: ConnectivityService)
class ConnectivityServiceImpl extends ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map((results) {
        final online = _isOnline(results);
        if (kDebugMode) {
          debugPrint('[Connectivity] event: $results -> online=$online');
        }
        return online;
      });

  @override
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }
}
