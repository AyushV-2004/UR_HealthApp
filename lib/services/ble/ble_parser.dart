import 'ble_data_provider.dart';
import '../../models/sensor_model.dart';
import '../firebase/firebase_service.dart';


class BleParser {
  static void parse(List<int> raw, BleDataProvider provider, {String? mac}) {
    final data = _maybeDecodeAscii(raw);

    if (data.length < 22) {
      print("⚠ Packet too short (${data.length}) → skipping");
      return;
    }

    print("🧾 HEX RAW PACKET: ${_toHex(data)}");

    if (data[1] != 0x02) {
      print("⚠ Not a sensor data packet");
      return;
    }

    final pm25 = data[10] + (data[11] << 8);
    final pm10 = data[12] + (data[13] << 8);
    final pm1 = data[14] + (data[15] << 8);
    final battery = data[16];
    final noise = data[17];
    final temperature = data[18] + data[19] / 10;
    final humidity = data[20] + data[21] / 10;

    provider.update(
      pm25: pm25.toDouble(),
      pm10: pm10.toDouble(),
      pm1: pm1.toDouble(),
      battery: battery.toDouble(),
      noise: noise.toDouble(),
      temperature: temperature,
      humidity: humidity,
    );

    final reading = SensorReading(
      pm25: pm25.toDouble(),
      pm10: pm10.toDouble(),
      pm1: pm1.toDouble(),
      temperature: temperature,
      humidity: humidity,
      noise: noise,
      battery: battery.toDouble(),
      timestamp: DateTime.now(),
    );

    if (mac != null) {
      FirebaseService()
          .saveReading(mac, reading.toJson())
          .then((_) {
        print("✅ Saved reading for $mac");
      });
    }

  }

  static List<int> _maybeDecodeAscii(List<int> raw) {
    // ASCII hex looks like: "37 65 30..."
    final isAscii = raw.every((b) =>
    (b >= 0x30 && b <= 0x39) || // 0-9
        (b >= 0x41 && b <= 0x46) || // A-F
        (b >= 0x61 && b <= 0x66) || // a-f
        b == 0x20); // space

    if (!isAscii) return raw;

    final hexStr = raw.map((e) => String.fromCharCode(e)).join();
    final clean = hexStr.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    final bytes = <int>[];
    for (int i = 0; i + 1 < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }

    return bytes;
  }

  static String _toHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }
}
