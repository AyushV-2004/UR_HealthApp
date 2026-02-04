import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../trends_controller.dart';

class TrendsChart extends StatelessWidget {
  final Stream<List<FlSpot>> dataStream;
  final MetricThreshold threshold;

  const TrendsChart({
    super.key,
    required this.dataStream,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FlSpot>>(
      stream: dataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),

            /// =======================
            /// THRESHOLD LINES
            /// =======================
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                _line(threshold.green, Colors.green),
                _line(threshold.yellow, Colors.orange),
                _line(threshold.red, Colors.red),
              ],
            ),

            /// =======================
            /// DATA LINE
            /// =======================
            lineBarsData: [
              LineChartBarData(
                spots: snapshot.data!,
                isCurved: true,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                color: Colors.blueAccent,
              ),
            ],
          ),
        );
      },
    );
  }

  /// =======================
  /// HELPER FOR THRESHOLD LINE
  /// =======================
  HorizontalLine _line(double y, Color color) {
    return HorizontalLine(
      y: y,
      color: color,
      strokeWidth: 1,
      dashArray: [6, 4],
    );
  }
}
