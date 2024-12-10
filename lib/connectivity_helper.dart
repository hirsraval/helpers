import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  bool hasInternet = true;
  StreamSubscription? _subscription;
  StreamController<bool>? _controller;

  static ConnectivityHelper? _instance;

  ConnectivityHelper._private();

  factory ConnectivityHelper() => _instance ??= ConnectivityHelper._private();

  Stream<bool> get onConnectivityChanged {
    final controller = _controller ??= StreamController<bool>.broadcast();
    return controller.stream;
  }

  void initialize() {
    Connectivity().checkConnectivity().then(_onConnectivityChange);
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
  }

  FutureOr _onConnectivityChange(List<ConnectivityResult> result) {
    hasInternet = !result.contains(ConnectivityResult.none);
    _controller?.add(hasInternet);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller?.close();
    _controller = null;
  }
}
