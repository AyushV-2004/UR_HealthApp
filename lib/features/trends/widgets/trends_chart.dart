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

class TrendsChart extends StatefulWidget {
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
  State<TrendsChart> createState() => _TrendsChartState();
}

class _TrendsChartState extends State<TrendsChart> {
  final List<double> _zoomLevels = [1.0, 2.0, 4.0];
  int _zoomIndex = 0;

  double get _zoomFactor => _zoomLevels[_zoomIndex];

  void _toggleZoom() {
    setState(() {
      _zoomIndex = (_zoomIndex + 1) % _zoomLevels.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FlSpot>>(
      stream: widget.dataStream,
      builder: (context, snapshot) {
        // =======================
        // SKELETON LOADER
        // =======================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 257,
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
        final totalRange = spots.last.x - spots.first.x;

        final visibleRange = totalRange / _zoomFactor;
        final maxX = spots.last.x;
        final minX = maxX - visibleRange;

        final lastValue = spots.last.y;

        // =======================
        // THRESHOLD COLOR LOGIC
        // =======================
        Color targetColor;
        if (lastValue <= widget.threshold.green) {
          targetColor = Colors.green;
        } else if (lastValue <= widget.threshold.yellow) {
          targetColor = Colors.orange;
        } else {
          targetColor = Colors.red;
        }

        return GestureDetector(
          onDoubleTap: _toggleZoom,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(begin: Colors.green, end: targetColor),
            duration: const Duration(milliseconds: 500),
            builder: (context, animatedColor, _) {
              return LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  minY: 0,
                  maxY: widget.maxY,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: widget.maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),

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
                        interval: visibleRange / 4,
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
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            spot.y.toStringAsFixed(1),
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),

                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      _line(widget.threshold.green, Colors.green),
                      _line(widget.threshold.yellow, Colors.orange),
                      _line(widget.threshold.red, Colors.red),
                    ],
                  ),

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
          ),
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
