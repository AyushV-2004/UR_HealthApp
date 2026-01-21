import 'package:flutter/material.dart';
import 'ur_card.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: UrCard(
        height: 85,
        backgroundColor: Colors.white,
        borderColor: const Color(0xFF90969E),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _icon(),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF90969E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF90969E)),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return const CircleAvatar(
      radius: 22,
      backgroundColor: Color(0xFF1DA1F2),
      child: Icon(Icons.person_outline, color: Colors.white),
    );
  }
}
