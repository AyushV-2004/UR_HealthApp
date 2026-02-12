import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../services/ble/ble_device_provider.dart';

import '../widgets/header.dart';
import '../widgets/exposure_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/environment_section.dart';
import '../widgets/checkin_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  /// 🔥 Firestore device stream (SOURCE OF TRUTH)
  Stream<DocumentSnapshot<Map<String, dynamic>>> _deviceStream(String mac) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<BleDeviceProvider>();

    /// ❌ No active device selected
    if (!deviceProvider.hasDevice) {
      return const Scaffold(
        body: Center(
          child: Text("No device connected"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _deviceStream(deviceProvider.mac!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text("No device data found"));
            }

            final deviceData = snapshot.data!.data()!;

            /// ✅ Latest snapshot data (written by SyncService)
            final readings =
            Map<String, dynamic>.from(deviceData['readings'] ?? {});

            /// ✅ Connection status from Firestore (NOT time guessing)
            final bool isConnected = deviceData['isConnected'] == true;

            final String deviceName =
                deviceData['deviceName'] ?? 'Unknown Device';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(
                    deviceName: deviceName,
                    isConnected: isConnected,
                  ),

                  const SizedBox(height: 16),

                  ExposureCard(
                    pm25: (readings['pm25'] ?? 0).toInt(),
                    pm10: (readings['pm10'] ?? 0).toInt(),
                  ),

                  const SizedBox(height: 16),

                  AlertCard(
                    pm25: (readings['pm25'] ?? 0).toInt(),
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

                  EnvironmentSection(
                    pm25: (readings['pm25'] ?? 0).toInt(),
                    pm10: (readings['pm10'] ?? 0).toInt(),
                    pm1: (readings['pm1'] ?? 0).toInt(),
                    temperature:
                    (readings['temperature'] ?? 0).toDouble(),
                    humidity:
                    (readings['humidity'] ?? 0).toDouble(),
                    noise: (readings['noise'] ?? 0).toInt(),
                  ),

                  const SizedBox(height: 24),

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
