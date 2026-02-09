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

  /// 🔄 MAIN SYNC METHOD (WITH PROGRESS)
  Future<void> syncNow({
    required String mac,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception("User not logged in");
      }

      // 🟡 1. CONNECTING
      syncProgress.setStage(SyncStage.connecting);

      // 🧹 Clear any previous leftover data
      dataProvider.clearBuffer();

      // 🔵 2. FETCHING DATA FROM DEVICE
      syncProgress.setStage(SyncStage.fetching);

      await bleService.syncAllData(
        onPacket: (raw) {
          BleParser.parse(raw, dataProvider);
        },
      );

      // ⏳ Give device time to finish sending flash data
      await Future.delayed(const Duration(seconds: 5));

      final readings = dataProvider.buffer;

      if (readings.isEmpty) {
        throw Exception("No readings received from device");
      }

      // 🟣 3. UPLOADING TO FIREBASE
      syncProgress.setStage(SyncStage.uploading);

      await firebaseService.batchSaveReadings(
        uid: uid,
        mac: mac,
        readings: readings,
      );

      await firebaseService.updateLastSync(uid, mac);

      // 🛑 Stop BLE notifications
      bleService.stopSync();

      // 🧹 Clear buffer after successful upload
      dataProvider.clearBuffer();

      // ✅ 4. SUCCESS
      syncProgress.setStage(SyncStage.success);

      // ⏱ Auto reset UI after short delay
      await Future.delayed(const Duration(seconds: 2));
      syncProgress.reset();
    } catch (e) {
      // ❌ FAILURE
      bleService.stopSync();
      syncProgress.setError(e.toString());
    }
  }
}
