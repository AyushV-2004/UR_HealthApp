import 'package:flutter/material.dart';
import '../trends_controller.dart';

class AboutSection extends StatelessWidget {
  final TrendMode mode;

  const AboutSection({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Text(
      mode == TrendMode.air
          ? 'Air quality shows pollution levels and health risk...'
          : 'Heat metrics indicate temperature stress and comfort...',
      style: const TextStyle(color: Colors.grey),
    );
  }
}
