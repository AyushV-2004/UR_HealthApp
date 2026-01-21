import 'package:flutter/material.dart';
import 'environment_card.dart';

class EnvironmentSection extends StatelessWidget {
  const EnvironmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 LEFT COLUMN
          Expanded(
            child: Column(
              children: const [
                EnvironmentCard(
                  title: "PM 2.5",
                  subtitle: "Fine particulate matter",
                  value: "12",
                  unit: "µg/m³",
                  status: "Good",
                  icon: Icons.air,
                ),
                SizedBox(height: 20),
                EnvironmentCard(
                  title: "PM 1",
                  subtitle: "Ultra Fine Particulate Matter",
                  value: "12",
                  unit: "µg/m³",
                  status: "Good",
                  icon: Icons.air,
                ),
                SizedBox(height: 20),
                EnvironmentCard(
                  title: "Temperature",
                  subtitle: "Comfortable Temperature",
                  value: "24",
                  unit: "°c",
                  status: "Good",
                  icon: Icons.thermostat,
                ),
                SizedBox(height: 20),
                EnvironmentCard(
                  title: "Noise",
                  subtitle: "Severe Sound Environment",
                  value: "66",
                  unit: "dB",
                  status: "Bad",
                  icon: Icons.volume_up,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// 🔹 RIGHT COLUMN
          Expanded(
            child: Column(
              children: const [
                EnvironmentCard(
                  title: "PM 10",
                  subtitle: "Coarse Particulate Matter",
                  value: "28",
                  unit: "µg/m³",
                  status: "Moderate",
                  icon: Icons.air,
                ),
                SizedBox(height: 20),
                EnvironmentCard(
                  title: "Heat Index",
                  subtitle: "Use Sun Protection",
                  value: "6",
                  unit: "index",
                  status: "Moderate",
                  icon: Icons.wb_sunny,
                ),
                SizedBox(height: 20),
                EnvironmentCard(
                  title: "Humidity",
                  subtitle: "Optimal Humidity Level",
                  value: "55",
                  unit: "%",
                  status: "Good",
                  icon: Icons.water_drop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
