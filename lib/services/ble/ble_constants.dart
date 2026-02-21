import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleConstants {
  static String? connectedDeviceId;
  static final Uuid uartService =
  Uuid.parse("6e400001-b5a3-f393-e0a9-e50e24dcca9e");

  static final Uuid rxChar =
  Uuid.parse("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

  static final Uuid txChar =
  Uuid.parse("6e400003-b5a3-f393-e0a9-e50e24dcca9e");

  //  BLE Commands

  static const List<int> getMacCommand = [0x7E, 0x09, 0x00, 0x00];
  static const List<int> getLastDataCommand = [0x7E, 0x02, 0x00, 0x00];

  static const List<int> getAllDataCommand = [0x7E, 0x03, 0x00, 0x00];
}
