import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/connectivity_state.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  Stream<SmritiConnectionState> watch() async* {
    yield await current();
    yield* _connectivity.onConnectivityChanged.map(_fromResults);
  }

  Future<SmritiConnectionState> current() async => _fromResults(await _connectivity.checkConnectivity());

  SmritiConnectionState _fromResults(List<ConnectivityResult> results) =>
      results.contains(ConnectivityResult.none) ? SmritiConnectionState.offline : SmritiConnectionState.connected;
}
