import 'package:flutter/material.dart';
class CheckInCard extends StatelessWidget {
  final DateTime? lastUpdated;

  const CheckInCard({super.key, this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FFF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF22C55E),
            child: Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today’s Check-in complete",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                lastUpdated == null
                    ? "No recent update"
                    : "Updated ${lastUpdated!.toLocal()}",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}