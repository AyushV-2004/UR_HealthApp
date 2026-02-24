//
// import 'dart:async';
//
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//
// import '../firebase/firebase_service.dart';
// import 'ble_constants.dart';
// import 'ble_connection_state.dart';
//
// class BleService {
//   final FlutterReactiveBle _ble = FlutterReactiveBle();
//
//   QualifiedCharacteristic? rx;
//   QualifiedCharacteristic? tx;
//
//   StreamSubscription<List<int>>? _notifySub;
//
//   /// 🔍 SCAN DEVICES
//   Stream<DiscoveredDevice> scanDevices() {
//     return _ble.scanForDevices(
//       withServices: const [],
//       scanMode: ScanMode.lowLatency,
//     );
//   }
//
//   /// 🔗 CONNECT DEVICE
//   Stream<DeviceConnectionState> connect(
//       String deviceId,
//       BleConnectionState connectionState,
//       ) {
//     rx = QualifiedCharacteristic(
//       deviceId: deviceId,
//       serviceId: BleConstants.uartService,
//       characteristicId: BleConstants.rxChar,
//     );
//
//     tx = QualifiedCharacteristic(
//       deviceId: deviceId,
//       serviceId: BleConstants.uartService,
//       characteristicId: BleConstants.txChar,
//     );
//
//     return _ble
//         .connectToDevice(
//       id: deviceId,
//       connectionTimeout: const Duration(seconds: 20),
//     )
//         .asyncMap((update) async {
//       if (update.connectionState ==
//           DeviceConnectionState.connected) {
//
//         connectionState.setConnected(true);
//
//         // 🔥 REQUEST MTU (CRITICAL)
//         try {
//           final mtu = await _ble.requestMtu(
//             deviceId: deviceId,
//             mtu: 247,
//           );
//           print("✅ MTU negotiated: $mtu");
//         } catch (e) {
//           print("⚠️ MTU request failed: $e");
//         }
//
//         await FirebaseService().updateDeviceStatus(
//           mac: deviceId,
//           isConnected: true,
//           location: "Bedroom",
//         );
//       }
//
//       if (update.connectionState ==
//           DeviceConnectionState.disconnected) {
//         connectionState.setConnected(false);
//         stopSync();
//       }
//
//       return update.connectionState;
//     });
//   }
//
//
//   /// ✅ BLE READY CHECK
//   bool get isReady => rx != null && tx != null;
//
//   /// 🔔 START NOTIFICATIONS (MUST BE FIRST)
//   Future<void> startNotificationListener({
//     required void Function(List<int>) onPacket,
//   }) async {
//     if (tx == null) {
//       throw Exception("TX characteristic not ready");
//     }
//
//     _notifySub = _ble.subscribeToCharacteristic(tx!).listen(
//           (data) {
//         print("📥 RAW BLE: $data");   // 👈 VERY IMPORTANT
//         onPacket(data);
//       },
//       onError: (e) {
//         print("❌ BLE notify error: $e");
//       },
//     );
//
//   }
//
//   /// 📤 SEND GET ALL DATA COMMAND
//   Future<void> sendGetAllCommand() async {
//     if (rx == null) {
//       throw Exception("RX characteristic not ready");
//     }
//
//     await _ble.writeCharacteristicWithoutResponse(
//       rx!,
//       value: BleConstants.getAllDataCommand,
//     );
//
//     print("📡 getAllDataCommand sent");
//   }
//
//   /// 🛑 STOP SYNC
//   void stopSync() {
//     _notifySub?.cancel();
//     _notifySub = null;
//     print("🛑 BLE sync stopped");
//   }
//
//   /// 📥 OPTIONAL READ (DEBUG)
//   Future<List<int>> readOnce() async {
//     if (tx == null) throw Exception("TX not ready");
//     return await _ble.readCharacteristic(tx!);
//   }
// }





import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../firebase/firebase_service.dart';
import 'ble_constants.dart';
import 'ble_connection_state.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  QualifiedCharacteristic? rx;
  QualifiedCharacteristic? tx;

  StreamSubscription<ConnectionStateUpdate>? _connectionSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isConnected = false;

  bool get isReady => _isConnected && rx != null && tx != null;

  /* ───────────────────────────────────────── */
/* 🔍 SCAN DEVICES                          */
/* ───────────────────────────────────────── */
  Stream<DiscoveredDevice> scanDevices() {
    return _ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    );
  }

  /* ───────────────────────────────────────── */
  /* 🔗 CONNECT DEVICE (KEEP STREAM ALIVE)   */
  /* ───────────────────────────────────────── */
  Future<void> connect(
      String deviceId,
      BleConnectionState connectionState,
      ) async {
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

    _connectionSub?.cancel();

    _connectionSub = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 20),
    )
        .listen((update) async {
      if (update.connectionState == DeviceConnectionState.connected) {
        print("🔗 Connected to device");
        _isConnected = true;
        connectionState.setConnected(true);

        await _requestMtu(deviceId);
        await _waitForBonding();
        await _discoverServices(deviceId);
        await _safeRtcSync(deviceId);

        await FirebaseService().updateDeviceStatus(
          mac: deviceId,
          isConnected: true,
          location: "Bedroom",
        );
      }

      if (update.connectionState == DeviceConnectionState.disconnected) {
        print("❌ Device disconnected");
        _isConnected = false;
        connectionState.setConnected(false);
        stopSync();
      }
    });
  }

  /* ───────────────────────────────────────── */
  Future<void> _requestMtu(String deviceId) async {
    try {
      final mtu = await _ble.requestMtu(
        deviceId: deviceId,
        mtu: 247,
      );
      print("✅ MTU negotiated: $mtu");
    } catch (e) {
      print("⚠️ MTU failed: $e");
    }
  }

  Future<void> _waitForBonding() async {
    print("⏳ Waiting for bonding...");
    await Future.delayed(const Duration(seconds: 3));
    print("✅ Bonding wait completed");
  }

  Future<void> _discoverServices(String deviceId) async {
    try {
      await _ble.discoverServices(deviceId);
      print("🔎 Services discovered");
    } catch (e) {
      print("❌ Discover failed: $e");
    }
  }

  Future<void> _safeRtcSync(String deviceId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      await _sendRtcSync();
      print("⏰ RTC synced");
    } catch (e) {
      print("⚠️ RTC failed: $e");
    }
  }

  Future<void> _sendRtcSync() async {
    if (rx == null) return;

    final now = DateTime.now().toUtc();
    final year = now.year.toString();

    final packet = Uint8List.fromList([
      0x7E,
      0x01,
      0x06,
      (now.day + now.month + int.parse(year.substring(0, 2)) +
          int.parse(year.substring(2)) +
          now.hour +
          now.minute) &
      0xFF,
      now.day,
      now.month,
      int.parse(year.substring(0, 2)),
      int.parse(year.substring(2)),
      now.hour,
      now.minute,
    ]);

    await _ble.writeCharacteristicWithResponse(rx!, value: packet);
    print("📡 RTC Packet Sent");
  }

  /* ───────────────────────────────────────── */
  /* 🔔 NOTIFICATIONS                          */
  /* ───────────────────────────────────────── */
  Future<void> startNotificationListener({
    required void Function(List<int>) onPacket,
  }) async {
    if (tx == null) throw Exception("TX not ready");

    await _notifySub?.cancel();

    _notifySub = _ble.subscribeToCharacteristic(tx!).listen(
          (data) {
        print("📥 RAW BLE: $data");
        onPacket(data);
      },
      onError: (e) => print("❌ Notify error: $e"),
    );
  }

  /* ───────────────────────────────────────── */
  Future<void> sendGetAllCommand() async {
    if (rx == null) throw Exception("RX not ready");

    await _ble.writeCharacteristicWithoutResponse(
      rx!,
      value: BleConstants.getAllDataCommand,
    );

    print("📡 getAllDataCommand sent");
  }

  void stopSync() {
    _notifySub?.cancel();
    print("🛑 BLE sync stopped");
  }
}