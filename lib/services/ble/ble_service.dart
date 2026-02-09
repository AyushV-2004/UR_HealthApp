import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../firebase/firebase_service.dart';
import 'ble_constants.dart';
import 'ble_connection_state.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  QualifiedCharacteristic? rx;
  QualifiedCharacteristic? tx;

  /// 🔔 Notification subscription (for sync)
  StreamSubscription<List<int>>? _notifySub;

  /// 🔍 SCAN DEVICES
  Stream<DiscoveredDevice> scanDevices() {
    return _ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    );
  }

  /// 🔗 CONNECT ONLY (NO DATA FLOW HERE)
  Stream<DeviceConnectionState> connect(
      String deviceId,
      BleConnectionState connectionState,
      ) {
    rx = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.rxChar,
    );

    tx = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.txChar,
    );

    return _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 20),
    )
        .map((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        connectionState.setConnected(true);

        FirebaseService().updateDeviceStatus(
          mac: deviceId,
          isConnected: true,
          location: "Bedroom",
        );
      }

      if (update.connectionState == DeviceConnectionState.disconnected) {
        connectionState.setConnected(false);
      }

      return update.connectionState;
    });
  }

  /// 📤 WRITE COMMAND (generic)
  Future<void> write(List<int> data) async {
    if (rx == null) return;
    await _ble.writeCharacteristicWithoutResponse(rx!, value: data);
  }

  /// 🔄 SYNC ALL DATA (FLASH → APP)
  Future<void> syncAllData({
    required void Function(List<int>) onPacket,
  }) async {
    if (rx == null || tx == null) {
      throw Exception("BLE characteristics not ready");
    }

    // 🔔 Subscribe to notifications
    _notifySub?.cancel();
    _notifySub = _ble
        .subscribeToCharacteristic(tx!)
        .listen(
      onPacket,
      onError: (e) {
        print("❌ BLE notify error: $e");
      },
    );

    // 📤 Fire GET ALL DATA command
    await _ble.writeCharacteristicWithoutResponse(
      rx!,
      value: BleConstants.getAllDataCommand,
    );

    print("📡 getAllDataCommand sent");
  }

  /// 🛑 STOP SYNC
  void stopSync() {
    _notifySub?.cancel();
    _notifySub = null;
    print("🛑 BLE sync stopped");
  }

  /// 📥 READ ONCE (OPTIONAL / DEBUG)
  Future<List<int>> readOnce() async {
    if (tx == null) throw Exception("TX not ready");
    return await _ble.readCharacteristic(tx!);
  }
}
