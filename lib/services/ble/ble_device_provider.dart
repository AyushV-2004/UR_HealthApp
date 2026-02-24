import 'package:flutter/material.dart';
import 'ble_service.dart';
import 'ble_connection_state.dart';
class BleDeviceProvider extends ChangeNotifier {
  final BleService bleService;
  final BleConnectionState connectionState;

  BleDeviceProvider({
    required this.bleService,
    required this.connectionState,
  });

  String? _mac;

  String? get mac => _mac;
  bool get hasDevice => _mac != null;

  bool get isConnected =>  _mac != null && connectionState.isConnected;

  void setDevice(String deviceId) {
    _mac = deviceId;
    notifyListeners();
  }

  void clear() {
    _mac = null;
    notifyListeners();
  }
}
