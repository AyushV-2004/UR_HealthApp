import 'package:flutter/material.dart';
class AlertCard extends StatelessWidget {
  final int pm25;

  const AlertCard({
    super.key,
    required this.pm25,
  });

  @override
  Widget build(BuildContext context) {
    final bool isModerate = pm25 > 35;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isModerate ? const Color(0xFFFFF4E5) : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isModerate
            ? "Moderate Conditions – Take care"
            : "All conditions are good",
      ),
    );
  }
}