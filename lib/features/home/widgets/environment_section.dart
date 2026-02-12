import 'package:flutter/material.dart';
import 'environment_card.dart';

class EnvironmentSection extends StatelessWidget {
  final int pm25;
  final int pm10;
  final int pm1;
  final double temperature;
  final double humidity;
  final int noise;

  const EnvironmentSection({
    super.key,
    required this.pm25,
    required this.pm10,
    required this.pm1,
    required this.temperature,
    required this.humidity,
    required this.noise,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LEFT COLUMN
        Expanded(
          child: Column(
            children: [
              EnvironmentCard(
                title: "PM 2.5",
                subtitle: "Fine particulate matter",
                value: pm25.toString(),
                unit: "µg/m³",
                status: _status(pm25),
                icon: Icons.air,
              ),
              const SizedBox(height: 20),
              EnvironmentCard(
                title: "PM 1",
                subtitle: "Ultra fine particles",
                value: pm1.toString(),
                unit: "µg/m³",
                status: _status(pm1),
                icon: Icons.air,
              ),
              const SizedBox(height: 20),
              EnvironmentCard(
                title: "Temperature",
                subtitle: "Comfort level",
                value: temperature.toStringAsFixed(1),
                unit: "°C",
                status: temperature > 30 ? "Bad" : "Good",
                icon: Icons.thermostat,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        /// RIGHT COLUMN
        Expanded(
          child: Column(
            children: [
              EnvironmentCard(
                title: "PM 10",
                subtitle: "Coarse particles",
                value: pm10.toString(),
                unit: "µg/m³",
                status: _status(pm10),
                icon: Icons.air,
              ),
              const SizedBox(height: 20),
              EnvironmentCard(
                title: "Humidity",
                subtitle: "Air moisture",
                value: humidity.toStringAsFixed(0),
                unit: "%",
                status: humidity > 70 ? "Bad" : "Good",
                icon: Icons.water_drop,
              ),
              const SizedBox(height: 20),
              EnvironmentCard(
                title: "Noise",
                subtitle: "Sound level",
                value: noise.toString(),
                unit: "dB",
                status: noise > 70 ? "Bad" : "Good",
                icon: Icons.volume_up,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _status(num? value) {
    if (value == null) return "—";
    if (value <= 50) return "Good";
    if (value <= 100) return "Moderate";
    return "Bad";
  }
}
