import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_constants.dart';
import 'ble_connection_state.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  QualifiedCharacteristic? rxCharacteristic;
  QualifiedCharacteristic? txCharacteristic;

  /// 🔍 Scan for BLE devices
  Stream<DiscoveredDevice> scanDevices() {
    return _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    );
  }

  /// 🔗 Connect to device
  void connect(String deviceId, BleConnectionState connectionState) {
    rxCharacteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.rxChar,
    );

    txCharacteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.txChar,
    );

    _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    ).listen((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        print("🟢 BLE connected");
        connectionState.setConnected(true);
      }

      if (update.connectionState == DeviceConnectionState.disconnected) {
        print("🔴 BLE disconnected");
        connectionState.setConnected(false);
      }
    });
  }

  /// 📡 Subscribe to TX notifications
  Stream<List<int>> subscribeToData() {
    return _ble.subscribeToCharacteristic(txCharacteristic!);
  }

  /// 📤 Write to RX
  Future<void> writeCommand(List<int> data) async {
    if (rxCharacteristic == null) {
      print("❗ RX characteristic not ready");
      return;
    }

    print("📤 Writing to RX: $data");

    await _ble.writeCharacteristicWithResponse(
      rxCharacteristic!,
      value: data,
    );
  }
}
