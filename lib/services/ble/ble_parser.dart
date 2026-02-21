import 'ble_data_provider.dart';

class BleParser {
  static void parse(
      List<int> raw,
      BleDataProvider provider,
      ) {
    final data = _maybeDecodeAscii(raw);

    if (data.length < 4) return;
    if (data[0] != 0x7E) return;
    if (data[1] != 0x02) return;

    try {
      final length = data[2];

      // 🔥 Validate full packet length
      if (data.length < length + 4) {
        print("⚠ Incomplete packet received");
        return;
      }

      // 🔥 Extract Timestamp (UTC)
      final day = data[4];
      final month = data[5];
      final year =
      int.parse("${data[6]}${data[7]}");
      final hour = data[8];
      final minute = data[9];

      final timestamp = DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
      );

      // 🔥 Extract Sensor Data
      final pm25 = data[10] + (data[11] << 8);
      final pm10 = data[12] + (data[13] << 8);
      final pm1  = data[14] + (data[15] << 8);
      final battery = data[16];
      final noise = data[17];
      final temperature =
          data[18] + data[19] / 10;

      final humidity =
          data[20] + data[21] / 10;

      final reading = {
        'timestamp': timestamp,
        'pm25': pm25,
        'pm10': pm10,
        'pm1': pm1,
        'battery': battery,
        'noise': noise,
        'temperature': temperature,
        'humidity': humidity,
      };

      provider.addReading(reading);

    } catch (e) {
      print("❌ Parsing error: $e");
    }
  }

  static List<int> _maybeDecodeAscii(List<int> raw) {
    final isAscii = raw.every(
          (b) =>
      (b >= 0x30 && b <= 0x39) ||
          (b >= 0x41 && b <= 0x46) ||
          (b >= 0x61 && b <= 0x66) ||
          b == 0x20,
    );

    if (!isAscii) return raw;

    final hexStr =
    raw.map((e) => String.fromCharCode(e)).join();

    final clean =
    hexStr.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    final bytes = <int>[];
    for (int i = 0; i + 1 < clean.length; i += 2) {
      bytes.add(
        int.parse(clean.substring(i, i + 2),
            radix: 16),
      );
    }

    return bytes;
  }
}
























// import 'ble_data_provider.dart';
//
// class BleParser {
//   static void parse(
//       List<int> raw,
//       BleDataProvider provider,
//       ) {
//     final data = _maybeDecodeAscii(raw);
//
//     // Minimum required length check
//     if (data.length < 20) return;
//
//     // Validate header (0x7E)
//     if (data[0] != 0x7E) return;
//
//     // Validate message type (0x02 = Get Buffer Response)
//     if (data[1] != 0x02) return;
//
//     try {
//       // 🔥 Extract RTC Timestamp from device
//       final day = data[4];
//       final month = data[5];
//       final year = int.parse("${data[6]}${data[7]}");
//       final hour = data[8];
//       final minute = data[9];
//
//       final timestamp = DateTime(
//         year,
//         month,
//         day,
//         hour,
//         minute,
//       );
//
//       // 🔥 Extract Sensor Data
//       final pm25 = data[10] + (data[11] << 8);
//       final pm10 = data[12] + (data[13] << 8);
//       final pm1  = data[14] + (data[15] << 8);
//       final battery = data[16];
//       final noise = data[17];
//       final temperature = data[18] + data[19] / 10;
//
//       final reading = {
//         'pm25': pm25,
//         'pm10': pm10,
//         'pm1': pm1,
//         'battery': battery,
//         'noise': noise,
//         'temperature': temperature,
//         'timestamp': timestamp,
//       };
//
//       provider.addReading(reading);
//
//     } catch (e) {
//       print("❌ Parsing error: $e");
//     }
//   }
//
//   static List<int> _maybeDecodeAscii(List<int> raw) {
//     final isAscii = raw.every(
//           (b) =>
//       (b >= 0x30 && b <= 0x39) ||
//           (b >= 0x41 && b <= 0x46) ||
//           (b >= 0x61 && b <= 0x66) ||
//           b == 0x20,
//     );
//
//     if (!isAscii) return raw;
//
//     final hexStr = raw.map((e) => String.fromCharCode(e)).join();
//     final clean = hexStr.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
//
//     final bytes = <int>[];
//     for (int i = 0; i + 1 < clean.length; i += 2) {
//       bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
//     }
//
//     return bytes;
//   }
// }

























//
// import 'ble_data_provider.dart';
//
// class BleParser {
//   static void parse(
//       List<int> raw,
//       BleDataProvider provider,
//       ) {
//     final data = _maybeDecodeAscii(raw);
//
//     if (data.length < 22) return;
//     if (data[1] != 0x02) return;
//
//     final reading = {
//       'pm25': data[10] + (data[11] << 8),
//       'pm10': data[12] + (data[13] << 8),
//       'pm1': data[14] + (data[15] << 8),
//       'battery': data[16],
//       'noise': data[17],
//       'temperature': data[18] + data[19] / 10,
//       'humidity': data[20] + data[21] / 10,
//       'timestamp': DateTime.now(),
//     };
//
//     provider.addReading(reading);
//   }
//
//   static List<int> _maybeDecodeAscii(List<int> raw) {
//     final isAscii = raw.every(
//           (b) =>
//       (b >= 0x30 && b <= 0x39) ||
//           (b >= 0x41 && b <= 0x46) ||
//           (b >= 0x61 && b <= 0x66) ||
//           b == 0x20,
//     );
//
//     if (!isAscii) return raw;
//
//     final hexStr = raw.map((e) => String.fromCharCode(e)).join();
//     final clean = hexStr.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
//
//     final bytes = <int>[];
//     for (int i = 0; i + 1 < clean.length; i += 2) {
//       bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
//     }
//
//     return bytes;
//   }
// }
//
