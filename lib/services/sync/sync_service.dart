//
// import 'dart:async';
//
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../ble/ble_service.dart';
// import '../ble/ble_parser.dart';
// import '../ble/ble_data_provider.dart';
// import '../firebase/firebase_service.dart';
//
// import 'sync_progress.dart';
//
// class SyncService {
//   final BleService bleService;
//   final BleDataProvider dataProvider;
//   final FirebaseService firebaseService;
//   final SyncProgress syncProgress;
//
//   SyncService({
//     required this.bleService,
//     required this.dataProvider,
//     required this.firebaseService,
//     required this.syncProgress,
//   });
//
//   /// 🔄 MAIN SYNC METHOD (ROBUST & ORDERED)
//   Future<void> syncNow({
//     required String mac,
//   }) async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) {
//         throw Exception("User not logged in");
//       }
//
//       // 🟡 1. CONNECTING (UI)
//       syncProgress.setStage(SyncStage.connecting);
//
//       // ✅ ENSURE BLE IS READY
//       if (!bleService.isReady) {
//         throw Exception("BLE not connected. Please connect device first.");
//       }
//
//       // 🧹 Clear any leftover data
//       dataProvider.clearBuffer();
//
//       // 🔵 2. START LISTENING FIRST
//       syncProgress.setStage(SyncStage.fetching);
//
//       await bleService.startNotificationListener(
//         onPacket: (raw) {
//           BleParser.parse(raw, dataProvider);
//         },
//       );
//
//       // ⏳ IMPORTANT: give CCCD time to enable
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // 📤 SEND GET ALL DATA COMMAND
//       await bleService.sendGetAllCommand();
//
//       // ⏳ WAIT FOR DEVICE TO STREAM FLASH DATA
//       await Future.delayed(const Duration(seconds: 6));
//
//       final readings = dataProvider.buffer;
//
//       if (readings.isEmpty) {
//         throw Exception("No data received from device");
//       }
//
//       // 🟣 3. UPLOAD TO FIREBASE
//       syncProgress.setStage(SyncStage.uploading);
//
//       await firebaseService.batchSaveReadings(
//         uid: uid,
//         mac: mac,
//         readings: readings,
//       );
//
//       await firebaseService.updateLastSync(uid, mac);
//
//       // 🛑 STOP BLE NOTIFICATIONS
//       bleService.stopSync();
//
//       // 🧹 Cleanup
//       dataProvider.clearBuffer();
//
//       // ✅ SUCCESS
//       syncProgress.setStage(SyncStage.success);
//
//       await Future.delayed(const Duration(seconds: 2));
//       syncProgress.reset();
//     } catch (e) {
//       bleService.stopSync();
//       syncProgress.setError(e.toString());
//     }
//   }
// }




import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../ble/ble_service.dart';
import '../ble/ble_parser.dart';
import '../ble/ble_data_provider.dart';
import '../firebase/firebase_service.dart';
import 'sync_progress.dart';

class SyncService {
  final BleService bleService;
  final BleDataProvider dataProvider;
  final FirebaseService firebaseService;
  final SyncProgress syncProgress;

  SyncService({
    required this.bleService,
    required this.dataProvider,
    required this.firebaseService,
    required this.syncProgress,
  });

  Future<void> syncNow({
    required String mac,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not logged in");
      }

      if (!bleService.isReady) {
        throw Exception("Device not connected");
      }

      syncProgress.setStage(SyncStage.fetching);

      // Clear previous buffer
      dataProvider.clearBuffer();

      print("🔔 Enabling notifications...");

      await bleService.startNotificationListener(
        onPacket: (raw) {
          print("📦 Packet received inside SyncService");
          BleParser.parse(raw, dataProvider);
        },
      );

      // Allow CCCD setup
      await Future.delayed(const Duration(seconds: 2));

      print("📡 Sending GET ALL DATA command...");
      await bleService.sendGetAllCommand();

      // Wait for flash streaming
      await Future.delayed(const Duration(seconds: 6));

      final readings = dataProvider.buffer;

      print("📊 Total parsed readings: ${readings.length}");

      if (readings.isEmpty) {
        throw Exception("No data received from device");
      }

      syncProgress.setStage(SyncStage.uploading);

      print("☁ Uploading to Firestore...");

      await firebaseService.batchSaveReadings(
        uid: uid,
        mac: mac,
        readings: readings,
      );

      await firebaseService.updateLastSync(uid, mac);

      print("✅ Upload completed");

      bleService.stopSync();
      dataProvider.clearBuffer();

      syncProgress.setStage(SyncStage.success);

      await Future.delayed(const Duration(seconds: 2));
      syncProgress.reset();
    } catch (e) {
      print("❌ SYNC ERROR: $e");
      bleService.stopSync();
      syncProgress.setError(e.toString());
    }
  }
}
