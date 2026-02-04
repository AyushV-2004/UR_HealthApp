import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/header.dart';
import '../widgets/exposure_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/environment_section.dart';
import '../widgets/checkin_card.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {

  /// 🔥 Firestore device stream (REAL-TIME)
  Stream<DocumentSnapshot<Map<String, dynamic>>> _deviceStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    /// ⚠️ IMPORTANT
    /// Replace this with ACTUAL device id / mac address
    const deviceId = 'FB:A2:9A:3F:A0:E1';

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId)
        .snapshots();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _deviceStream(),
          builder: (context, snapshot) {

            /// ⏳ Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ❌ No data
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text("No device data found"));
            }

            final deviceData = snapshot.data!.data()!;

            /// 🔍 Latest readings (FIRST — very important)
            final Map<String, dynamic> readings =
            Map<String, dynamic>.from(deviceData['readings'] ?? {});

            /// 🔍 Timestamp-based connection logic
            final Timestamp? lastTs = readings['timestamp'] as Timestamp?;

            bool isConnected = false;
            if (lastTs != null) {
              final lastTime = lastTs.toDate();
              isConnected =
                  DateTime
                      .now()
                      .difference(lastTime)
                      .inSeconds < 30;
            }

            /// 🔍 Device name
            final String deviceName =
                deviceData['deviceName'] ?? 'Unknown Device';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔝 Header
                  HomeHeader(
                    deviceName: deviceName,
                    isConnected: isConnected,
                  ),

                  const SizedBox(height: 16),

                  /// 📊 Exposure
                  ExposureCard(
                    pm25: (readings['pm25'] ?? 0) as int,
                    pm10: (readings['pm10'] ?? 0) as int,
                  ),

                  const SizedBox(height: 16),

                  /// 🚨 Alerts
                  AlertCard(
                    pm25: (readings['pm25'] ?? 0) as int,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Environment",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🌡 Environment
                  EnvironmentSection(
                    pm25: (readings['pm25'] ?? 0) as int,
                    pm10: (readings['pm10'] ?? 0) as int,
                    pm1: (readings['pm1'] ?? 0) as int,
                    temperature:
                    (readings['temperature'] ?? 0).toDouble(),
                    humidity:
                    (readings['humidity'] ?? 0).toDouble(),
                    noise: (readings['noise'] ?? 0) as int,
                  ),

                  const SizedBox(height: 24),

                  /// ✅ Check-in
                  CheckInCard(
                    lastUpdated:
                    (readings['timestamp'] as Timestamp?)?.toDate(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}