import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityManager {
  static final _instance = ConnectivityManager._();

  static ConnectivityManager get instance {
    return _instance;
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityState> _connectivityController =
      StreamController.broadcast();

  ConnectivityManager._() {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResult) {
      if (connectivityResult.length == 1 &&
          connectivityResult.contains(ConnectivityResult.none)) {
        _connectivityController.add(ConnectivityState.none);
      } else {
        if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
          _connectivityController.add(ConnectivityState.hasBluetooth);
        }

        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi) ||
            connectivityResult.contains(ConnectivityResult.ethernet)) {
          _connectivityController.add(ConnectivityState.hasNetwork);
        }
      }
    });
  }

  Stream<ConnectivityState> get connectivityStream =>
      _connectivityController.stream;

  Future<bool> checkIfMobileNetworkConnectionAvailable() async {
    var connectivity = await _connectivity.checkConnectivity();
    return connectivity.contains(ConnectivityResult.mobile);
  }

  Future<bool> checkIfWiFiNetworkConnectionAvailable() async {
    var connectivity = await _connectivity.checkConnectivity();
    return connectivity.contains(ConnectivityResult.wifi);
  }

  Future<bool> checkIfEthernetNetworkConnectionAvailable() async {
    var connectivity = await _connectivity.checkConnectivity();
    return connectivity.contains(ConnectivityResult.ethernet);
  }

  Future<bool> checkIfNetworkConnectionAvailable() async {
    var connectivity = await _connectivity.checkConnectivity();
    return connectivity.contains(ConnectivityResult.wifi) ||
        connectivity.contains(ConnectivityResult.mobile) ||
        connectivity.contains(ConnectivityResult.ethernet);
  }
}

enum ConnectivityState { hasBluetooth, hasNetwork, none }
