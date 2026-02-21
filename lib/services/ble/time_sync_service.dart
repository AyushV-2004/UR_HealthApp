import 'dart:typed_data';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_constants.dart';

class TimeSyncService {
  final FlutterReactiveBle _ble;

  TimeSyncService(this._ble);

  Future<void> syncTime(String deviceId) async {
    final rxCharacteristic = QualifiedCharacteristic(
      serviceId: BleConstants.uartService,
      characteristicId: BleConstants.rxChar,
      deviceId: deviceId,
    );

    final now = DateTime.now().toUtc();

    final day = now.day;
    final month = now.month;

    final yearFull = now.year;
    final year1 = int.parse(yearFull.toString().substring(0, 2)); // 20
    final year2 = int.parse(yearFull.toString().substring(2));    // 26

    final hour = now.hour;
    final minute = now.minute;

    // Calculate checksum (simple 8-bit sum of data bytes)
    final checksum =
    (day + month + year1 + year2 + hour + minute) & 0xFF;

    final packet = Uint8List.fromList([
      0x7E,          // Header
      0x01,          // RTC Set Command
      0x06,          // Length
      checksum,      // Checksum
      day,
      month,
      year1,
      year2,
      hour,
      minute,
    ]);

    await _ble.writeCharacteristicWithResponse(
      rxCharacteristic,
      value: packet,
    );

    print("✅ RTC sync sent: $now");
  }
}