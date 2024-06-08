import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService with ChangeNotifier {
  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _hasConnection = result != ConnectivityResult.none;
      notifyListeners();
    });

    // Initial check
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _hasConnection = connectivityResult != ConnectivityResult.none;
    notifyListeners();
  }
}
