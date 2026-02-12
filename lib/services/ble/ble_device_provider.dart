import 'package:flutter/material.dart';

class BleDeviceProvider extends ChangeNotifier {
  String? _mac;

  String? get mac => _mac;
  bool get hasDevice => _mac != null;

  void setMac(String value) {
    _mac = value;
    notifyListeners();
  }

  void clear() {
    _mac = null;
    notifyListeners();
  }
}
