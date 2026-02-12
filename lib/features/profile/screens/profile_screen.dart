import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/firebase/history_service.dart';
import '../widgets/profile_card.dart';
import '../widgets/device_status_card.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_tile.dart';
import '../widgets/switch_tile.dart';

import '../../devices/screens/device_list_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dailyReminder = true;
  bool doNotDisturb = false;

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "UrProfile",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              /// 👤 USER PROFILE (Firestore-driven, always tappable)
              uid == null
                  ? ProfileCard(
                name: "Guest",
                email: "",
                onTap: () {},
              )
                  : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final data =
                  snapshot.data?.data() as Map<String, dynamic>?;

                  return ProfileCard(
                    name: data?['name'] ?? "User",
                    email: data?['email'] ?? "",
                    onTap: () => _openEditProfile(context),
                  );
                },
              ),

              const SizedBox(height: 12),

              /// 🔗 DEVICE STATUS (Firestore-driven)
            StreamBuilder<QuerySnapshot>(
              stream: HistoryService.devicesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const DeviceStatusCard(
                    deviceName: "UrHealth Air Monitor",
                    status: "Not Connected",
                  );
                }

                final connectedDevices = snapshot.data!.docs
                    .where((d) => d['isConnected'] == true)
                    .toList();

                if (connectedDevices.isEmpty) {
                  return const DeviceStatusCard(
                    deviceName: "UrHealth Air Monitor",
                    status: "Not Connected",
                  );
                }

                final device = connectedDevices.first;
                final data = device.data() as Map<String, dynamic>;

                return DeviceStatusCard(
                  deviceName: data['deviceName'] ?? 'UrHealth Air Monitor',
                  status: "Connected",
                );
              },
            ),

              const SizedBox(height: 24),
              const SectionTitle(text: "PERSONAL"),

              SettingsTile(
                title: "Personal Information",
                subtitle: "Name, age, health conditions",
                onTap: () => _openEditProfile(context),
              ),

              SettingsTile(
                title: "Units & Preferences",
                subtitle: "Metric, Fahrenheit, etc.",
                onTap: () {},
              ),

              const SizedBox(height: 24),
              const SectionTitle(text: "DEVICES"),

              /// 🔌 CONNECTED DEVICES SUMMARY
          StreamBuilder<QuerySnapshot>(
            stream: HistoryService.devicesStream(),
            builder: (context, snapshot) {
              String subtitle = "Not connected";

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final connectedDevices = snapshot.data!.docs
                    .where((d) => d['isConnected'] == true)
                    .toList();

                if (connectedDevices.isNotEmpty) {
                  subtitle = "Connected • ${connectedDevices.length} device(s)";
                }
              }

              return SettingsTile(
                title: "Connected Devices",
                subtitle: subtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DeviceListScreen(),
                    ),
                  );
                },
              );
            },
          ),

              const SizedBox(height: 24),
              const SectionTitle(text: "NOTIFICATIONS"),

              SwitchTile(
                title: "Daily Check-in Reminder",
                value: dailyReminder,
                onChanged: (v) =>
                    setState(() => dailyReminder = v),
              ),

              SwitchTile(
                title: "Do Not Disturb",
                value: doNotDisturb,
                onChanged: (v) =>
                    setState(() => doNotDisturb = v),
              ),

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "UrHealth v1.0.0",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
