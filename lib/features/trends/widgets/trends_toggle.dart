import 'package:flutter/material.dart';
import '../trends_controller.dart';

class TrendsToggle extends StatelessWidget {
  final TrendsController controller;

  const TrendsToggle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Heat'),
        Switch(
          value: controller.mode == TrendMode.air,
          onChanged: (val) {
            controller.toggleMode(
              val ? TrendMode.air : TrendMode.heat,
            );
          },
        ),
        const Text('Air'),
      ],
    );
  }
}
