
class SensorReading {
  final double pm25;
  final double pm10;
  final double pm1;
  final double temperature;
  final double humidity;
  final int noise;
  final double battery;
  final DateTime timestamp;

  SensorReading({
    required this.pm25,
    required this.pm10,
    required this.pm1,
    required this.temperature,
    required this.humidity,
    required this.noise,
    required this.battery,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'pm25': pm25,
    'pm10': pm10,
    'pm1': pm1,
    'temperature': temperature,
    'humidity': humidity,
    'noise': noise,
    'battery': battery,
    'timestamp': timestamp,
  };
}
