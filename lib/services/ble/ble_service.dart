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

  StreamSubscription<List<int>>? _notifySub;

  /// 🔍 SCAN DEVICES
  Stream<DiscoveredDevice> scanDevices() {
    return _ble.scanForDevices(
      withServices: const [],
      scanMode: ScanMode.lowLatency,
    );
  }

  /// 🔗 CONNECT DEVICE
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
        .asyncMap((update) async {
      if (update.connectionState ==
          DeviceConnectionState.connected) {

        connectionState.setConnected(true);

        // 🔥 1️⃣ REQUEST MTU
        try {
          final mtu = await _ble.requestMtu(
            deviceId: deviceId,
            mtu: 247,
          );
          print("✅ MTU negotiated: $mtu");
        } catch (e) {
          print("⚠️ MTU request failed: $e");
        }

        // 🔥 2️⃣ UPDATE FIRESTORE
        await FirebaseService().updateDeviceStatus(
          mac: deviceId,
          isConnected: true,
          location: "Bedroom",
        );

        // 🔥 3️⃣ AUTO TIME SYNC (IMPORTANT)
        try {
          await Future.delayed(
              const Duration(milliseconds: 300));

          await _sendRtcSync(deviceId);

          print("⏰ RTC synced successfully");
        } catch (e) {
          print("⚠️ RTC sync failed: $e");
        }
      }

      if (update.connectionState ==
          DeviceConnectionState.disconnected) {
        connectionState.setConnected(false);
        stopSync();
      }

      return update.connectionState;
    });
  }

  /// 🔥 RTC SYNC (PDF PROTOCOL FORMAT)
  Future<void> _sendRtcSync(String deviceId) async {
    if (rx == null) {
      throw Exception("RX characteristic not ready");
    }

    final now = DateTime.now().toUtc();

    final day = now.day;
    final month = now.month;

    final yearFull = now.year.toString();
    final year1 = int.parse(yearFull.substring(0, 2)); // 20
    final year2 = int.parse(yearFull.substring(2));    // 26

    final hour = now.hour;
    final minute = now.minute;

    // 8-bit checksum of data bytes
    final checksum =
    (day + month + year1 + year2 + hour + minute) & 0xFF;

    final packet = Uint8List.fromList([
      0x7E,        // Header
      0x01,        // RTC Set Command
      0x06,        // Length
      checksum,    // Checksum
      day,
      month,
      year1,
      year2,
      hour,
      minute,
    ]);

    await _ble.writeCharacteristicWithResponse(
      rx!,
      value: packet,
    );

    print("📡 RTC Packet Sent: $packet");
  }

  /// ✅ BLE READY CHECK
  bool get isReady => rx != null && tx != null;

  /// 🔔 START NOTIFICATIONS
  Future<void> startNotificationListener({
    required void Function(List<int>) onPacket,
  }) async {
    if (tx == null) {
      throw Exception("TX characteristic not ready");
    }

    _notifySub = _ble.subscribeToCharacteristic(tx!).listen(
          (data) {
        print("📥 RAW BLE: $data");
        onPacket(data);
      },
      onError: (e) {
        print("❌ BLE notify error: $e");
      },
    );
  }

  /// 📤 SEND GET ALL DATA COMMAND
  Future<void> sendGetAllCommand() async {
    if (rx == null) {
      throw Exception("RX characteristic not ready");
    }

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

  /// 📥 OPTIONAL READ
  Future<List<int>> readOnce() async {
    if (tx == null) throw Exception("TX not ready");
    return await _ble.readCharacteristic(tx!);
  }
}