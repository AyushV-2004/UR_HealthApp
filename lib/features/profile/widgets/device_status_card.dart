import 'package:flutter/material.dart';
import 'ur_card.dart';

class DeviceStatusCard extends StatelessWidget {
  final String deviceName;
  final String status;

  const DeviceStatusCard({
    super.key,
    required this.deviceName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return UrCard(
      height: 85,
      backgroundColor: const Color(0xFFDAFFED),
      borderColor: const Color(0xFF61FFB2),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF1DA1F2),
            child: Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2BB673),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
