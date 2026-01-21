import 'package:flutter/material.dart';

class BleConnectionState extends ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setConnected(bool value) {
    // if (_isConnected != value) {
    _isConnected = value;
    notifyListeners();
  }
}
