import 'package:flutter/material.dart';
import '../trends_controller.dart';

class TimeRangeSelector extends StatelessWidget {
  final TrendsController controller;
  const TimeRangeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('1h', TimeRange.hour1),
        _chip('24h', TimeRange.hour24),
        _chip('7d', TimeRange.day7),
      ],
    );
  }

  Widget _chip(String label, TimeRange range) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: controller.range == range,
        onSelected: (_) => controller.setRange(range),
      ),
    );
  }
}
