// import 'dart:typed_data';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'ble_constants.dart';
//
// class TimeSyncService {
//   final FlutterReactiveBle _ble;
//
//   TimeSyncService(this._ble);
//
//   /// 🔥 Sync device RTC with LOCAL device time (IST / GMT+5:30)
//   Future<void> syncTime(String deviceId) async {
//     final rxCharacteristic = QualifiedCharacteristic(
//       serviceId: BleConstants.uartService,
//       characteristicId: BleConstants.rxChar,
//       deviceId: deviceId,
//     );
//
//     /// ✅ Use LOCAL time directly (no manual offset)
//     final now = DateTime.now();
//
//     final int day = now.day;
//     final int month = now.month;
//     final int year = now.year;
//
//     final int hour = now.hour;
//     final int minute = now.minute;
//
//     /// Split year into two bytes (e.g. 2026 -> 20, 26)
//     final int yearHigh = year ~/ 100;   // 20
//     final int yearLow = year % 100;     // 26
//
//     /// 8-bit checksum (sum of data bytes & 0xFF)
//     final int checksum =
//     (day + month + yearHigh + yearLow + hour + minute) & 0xFF;
//
//     final packet = Uint8List.fromList([
//       0x7E,        // Header
//       0x01,        // RTC Set Command
//       0x06,        // Length
//       checksum,    // Checksum
//       day,
//       month,
//       yearHigh,
//       yearLow,
//       hour,
//       minute,
//     ]);
//
//     try {
//       await _ble.writeCharacteristicWithResponse(
//         rxCharacteristic,
//         value: packet,
//       );
//
//       print("✅ RTC sync sent (IST): $now");
//       print("📦 RTC Packet: $packet");
//     } catch (e) {
//       print("❌ RTC sync failed: $e");
//       rethrow;
//     }
//   }
// }









import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_constants.dart';

class TimeSyncService {
  final FlutterReactiveBle _ble;

  TimeSyncService(this._ble);

  /// 🔥 Sync device RTC using STRICT UTC (Protocol Requirement)

  Future<void> syncTime(String deviceId) async {
    final rxCharacteristic = QualifiedCharacteristic(
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.rxChar,
      deviceId: deviceId,
    );

    /// ✅ MUST use UTC (as per firmware protocol)
    // final nowUtc = DateTime.now().toUtc();
    final now = DateTime.now();

    print("🕒 Local Time       : $now");
    print("🌍 Time Zone Name   : ${now.timeZoneName}");
    print("⏳ Time Zone Offset : ${now.timeZoneOffset}");
    final int day = now.day;
    final int month = now.month;
    final int year = now.year;

    /// Split year (2026 → 20 & 26)
    final int yearHigh = year ~/ 100;
    final int yearLow = year % 100;

    /// ✅ Use 24-hour format (device clearly supports it)
    final int hour = now.hour;
    final int minute = now.minute;

    /// 8-bit checksum of data bytes only
    final int checksum =
    (day + month + yearHigh + yearLow + hour + minute) & 0xFF;

    final packet = Uint8List.fromList([
      0x7E,        // Header
      0x01,        // RTC Set Command
      0x06,        // Length
      checksum,    // Checksum
      day,
      month,
      yearHigh,
      yearLow,
      hour,
      minute,
    ]);

    try {
      await _ble.writeCharacteristicWithResponse(
        rxCharacteristic,
        value: packet,
      );

      print("✅ RTC sync sent (UTC): $now");
      print("📦 RTC Packet (HEX): "
          "${packet.map((e) => e.toRadixString(16).padLeft(2, '0')).toList()}");
    } catch (e) {
      print("❌ RTC sync failed: $e");
      rethrow;
    }
  }
}