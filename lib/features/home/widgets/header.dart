import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🏠 Home Header
class HomeHeader extends StatelessWidget {
  final String deviceName;
  final bool isConnected;

  const HomeHeader({
    super.key,
    required this.deviceName,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      height: 66,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
      child: user == null
          ? _buildHeader("User")
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String userName = "User";

          if (snapshot.hasData && snapshot.data!.exists) {
            final data =
            snapshot.data!.data() as Map<String, dynamic>;
            userName = data['name'] ?? "User";
          }

          return _buildHeader(userName);
        },
      ),
        ),
    );
  }

  Widget _buildHeader(String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi, $userName",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$deviceName • ${isConnected ? "Connected" : "Disconnected"}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const _NotificationIcon(hasUnread: true),
      ],
    );
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