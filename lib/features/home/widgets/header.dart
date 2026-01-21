import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🏠 Home Header
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      width: 335,
      height: 66,
      child: user == null
          ? _buildFallback()
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = "User";

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? "User";
          }

          return _buildHeader(userName);
        },
      ),
    );
  }

  /// 🔹 Header UI
  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// 👋 Left Section (Greeting + Location)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  "Hi, $userName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Color(0xFF1A1A1A),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: const [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
                SizedBox(width: 4),
                Text(
                  "Delhi, India.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Last synced 1 min ago",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),

        /// 🔔 Right Section (Notification + Settings)
        Row(
          children: const [
            _NotificationIcon(hasUnread: true),
            SizedBox(width: 12),
            _SettingsIcon(),
          ],
        ),
      ],
    );
  }

  /// Fallback UI if user is null
  Widget _buildFallback() {
    return _buildHeader("User");
  }
}

/// 🔔 Notification Icon
class _NotificationIcon extends StatelessWidget {
  final bool hasUnread;

  const _NotificationIcon({this.hasUnread = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.notifications_none,
              size: 22,
              color: Color(0xFF282828),
            ),
            onPressed: () {},
          ),
          if (hasUnread)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ⚙️ Settings Icon
class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.settings_outlined,
          size: 20,
          color: Color(0xFF282828),
        ),
        onPressed: () {},
      ),
    );
  }
}
