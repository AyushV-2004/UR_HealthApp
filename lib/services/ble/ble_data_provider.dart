import 'package:flutter/material.dart';

class BleDataProvider extends ChangeNotifier {
  double temperature = 0;
  double humidity = 0;
  double pm25 = 0;
  double pm1 = 0;
  double pm10 = 0;
  double uv = 0;
  double noise = 0;
  double battery = 0;

  void update({
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
}
