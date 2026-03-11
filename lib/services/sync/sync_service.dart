//
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../ble/ble_service.dart';
// import '../ble/ble_parser.dart';
// import '../ble/ble_data_provider.dart';
// import '../firebase/firebase_service.dart';
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
//   Future<void> syncNow({
//     required String mac,
//   }) async {
//     try {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid == null) {
//         throw Exception("User not logged in");
//       }
//
//       if (!bleService.isReady) {
//         throw Exception("Device not connected");
//       }
//
//       syncProgress.setStage(SyncStage.fetching);
//
//       // Clear previous buffer
//       dataProvider.clearBuffer();
//
//       print("🔔 Enabling notifications...");
//
//       await bleService.startNotificationListener(
//         onPacket: (raw) {
//           print("📦 Packet received inside SyncService");
//           BleParser.parse(raw, dataProvider);
//         },
//       );
//
//       // Allow CCCD setup
//       await Future.delayed(const Duration(seconds: 2));
//
//       print("📡 Sending GET ALL DATA command...");
//       await bleService.sendGetAllCommand();
//
//       // Wait for flash streaming
//       await Future.delayed(const Duration(seconds: 6));
//
//       final readings = dataProvider.buffer;
//
//       print("📊 Total parsed readings: ${readings.length}");
//
//       if (readings.isEmpty) {
//         throw Exception("No data received from device");
//       }
//
//       syncProgress.setStage(SyncStage.uploading);
//
//       print("☁ Uploading to Firestore...");
//
//       await firebaseService.batchSaveReadings(
//         uid: uid,
//         mac: mac,
//         readings: readings,
//       );
//
//       await firebaseService.updateLastSync(uid, mac);
//
//       print("✅ Upload completed");
//
//       bleService.stopSync();
//       dataProvider.clearBuffer();
//
//       syncProgress.setStage(SyncStage.success);
//
//       await Future.delayed(const Duration(seconds: 2));
//       syncProgress.reset();
//     } catch (e) {
//       print("❌ SYNC ERROR: $e");
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

  // ⏳ Timer to detect end of BLE stream
  Timer? _inactivityTimer;

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

      // 🧹 Clear previous buffer
      dataProvider.clearBuffer();

      print("🔔 Enabling notifications...");

      await bleService.startNotificationListener(
        onPacket: (raw) {
          print("📦 Packet received inside SyncService");

          // 🔍 Parse packet → pushes data into buffer
          BleParser.parse(raw, dataProvider);

          // ♻ Reset inactivity timer on every packet
          _inactivityTimer?.cancel();
          _inactivityTimer = Timer(const Duration(seconds: 2), () async {
            print("⏳ No packets for 2s → Processing data");
            await _processAndUpload(uid: uid, mac: mac);
          });
        },
      );

      // Allow CCCD setup
      await Future.delayed(const Duration(seconds: 2));

      print("📡 Sending GET ALL DATA command...");
      await bleService.sendGetAllCommand();
    } catch (e) {
      print("❌ SYNC ERROR: $e");
      _inactivityTimer?.cancel();
      bleService.stopSync();
      syncProgress.setError(e.toString());
    }
  }

  // ☁ Process parsed data & upload safely
  Future<void> _processAndUpload({
    required String uid,
    required String mac,
  }) async {
    try {
      final readings = dataProvider.buffer;

      print("📊 Final parsed readings: ${readings.length}");

      if (readings.isEmpty) {
        print("⚠ No readings to upload");
        return;
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
      print("❌ Upload error: $e");
      syncProgress.setError(e.toString());
    }
  }

  void dispose() {
    _inactivityTimer?.cancel();
  }
}