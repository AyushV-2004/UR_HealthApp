// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// import '../trends_controller.dart';
//
// class TrendsChart extends StatelessWidget {
//   final Stream<List<FlSpot>> dataStream;
//   final MetricThreshold threshold;
//
//   const TrendsChart({
//     super.key,
//     required this.dataStream,
//     required this.threshold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<FlSpot>>(
//       stream: dataStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No data available'));
//         }
//
//         return LineChart(
//           LineChartData(
//             gridData: const FlGridData(show: true),
//             titlesData: const FlTitlesData(show: false),
//             borderData: FlBorderData(show: false),
//
//             /// =======================
//             /// THRESHOLD LINES
//             /// =======================
//             extraLinesData: ExtraLinesData(
//               horizontalLines: [
//                 _line(threshold.green, Colors.green),
//                 _line(threshold.yellow, Colors.orange),
//                 _line(threshold.red, Colors.red),
//               ],
//             ),
//
//             /// =======================
//             /// DATA LINE
//             /// =======================
//             lineBarsData: [
//               LineChartBarData(
//                 spots: snapshot.data!,
//                 isCurved: true,
//                 barWidth: 2,
//                 dotData: const FlDotData(show: false),
//                 color: Colors.blueAccent,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   /// =======================
//   /// HELPER FOR THRESHOLD LINE
//   /// =======================
//   HorizontalLine _line(double y, Color color) {
//     return HorizontalLine(
//       y: y,
//       color: color,
//       strokeWidth: 1,
//       dashArray: [6, 4],
//     );
//   }
// }














import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../trends_controller.dart';

class TrendsChart extends StatelessWidget {
  final Stream<List<FlSpot>> dataStream;
  final MetricThreshold threshold;
  final double maxY;

  const TrendsChart({
    super.key,
    required this.dataStream,
    required this.threshold,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FlSpot>>(
      stream: dataStream,
      builder: (context, snapshot) {
        // =======================
        // SKELETON LOADER
        // =======================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final spots = snapshot.data!;
        final lastValue = spots.last.y;

        // =======================
        // THRESHOLD AWARE COLOR
        // =======================
        Color targetColor;
        if (lastValue <= threshold.green) {
          targetColor = Colors.green;
        } else if (lastValue <= threshold.yellow) {
          targetColor = Colors.orange;
        } else {
          targetColor = Colors.red;
        }

        // =======================
        // SMOOTH COLOR ANIMATION
        // =======================
        return TweenAnimationBuilder<Color?>(
          tween: ColorTween(begin: Colors.green, end: targetColor),
          duration: const Duration(milliseconds: 600),
          builder: (context, animatedColor, _) {
            return LineChart(
              LineChartData(
                minX: spots.first.x,
                maxX: spots.last.x,
                minY: 0,
                maxY: maxY,

                /// =======================
                /// GRID
                /// =======================
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),

                /// =======================
                /// X-AXIS (TIME LABELS)
                /// =======================
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (spots.length / 4).floorToDouble(),
                      getTitlesWidget: (value, meta) {
                        final minutesAgo =
                        ((spots.last.x - value) * 5).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '-${minutesAgo}m',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,

                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),

                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final minutesAgo =
                        ((spots.last.x - spot.x) * 5).toInt();

                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}\n-${minutesAgo} min',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),

                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.grey.withValues(alpha: 0.4),
                          strokeWidth: 1,
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            return FlDotCirclePainter(
                              radius: 5,
                              color: bar.color ?? Colors.blue,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),


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
                /// MAIN LINE
                /// =======================
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: animatedColor!,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          animatedColor.withValues(alpha: 0.3),
                          animatedColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  HorizontalLine _line(double y, Color color) {
    return HorizontalLine(
      y: y,
      color: color.withValues(alpha: 0.8),
      strokeWidth: 1,
      dashArray: [6, 4],
    );
  }
}
