import 'package:flutter/material.dart';

class BleDataProvider extends ChangeNotifier {
  /// 🔵 LIVE DATA (used by UI)
  double temperature = 0;
  double humidity = 0;
  double pm25 = 0;
  double pm1 = 0;
  double pm10 = 0;
  double uv = 0;
  double noise = 0;
  double battery = 0;

  /// 🧺 SYNC BUFFER (used only during Sync Now)
  final List<Map<String, dynamic>> _buffer = [];

  List<Map<String, dynamic>> get buffer => List.unmodifiable(_buffer);

  /// 🔄 Update LIVE values (used only for last packet)
  void updateLive({
    double? temperature,
    double? humidity,
    double? pm25,
    double? pm10,
    double? pm1,
    double? uv,
    double? noise,
    double? battery,
  }) {
    if (temperature != null) this.temperature = temperature;
    if (humidity != null) this.humidity = humidity;
    if (pm25 != null) this.pm25 = pm25;
    if (pm1 != null) this.pm1 = pm1;
    if (pm10 != null) this.pm10 = pm10;
    if (uv != null) this.uv = uv;
    if (noise != null) this.noise = noise;
    if (battery != null) this.battery = battery;

    notifyListeners();
  }

  /// ➕ Add reading to SYNC buffer
  void addReading(Map<String, dynamic> reading) {
    _buffer.add(reading);
  }

  /// 🧹 Clear buffer after successful sync
  void clearBuffer() {
    _buffer.clear();
  }
}
