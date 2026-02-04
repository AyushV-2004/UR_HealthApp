import 'package:flutter/material.dart';
class EnvironmentContextCard extends StatelessWidget {
  const EnvironmentContextCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity, // ✅ KEY FIX
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFFFA726)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Environment Context",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9800),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Based on today’s moderate PM10 levels, you might notice "
                  "slightly reduced endurance during outdoor activities. "
                  "Your heart rate is responding normally.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
