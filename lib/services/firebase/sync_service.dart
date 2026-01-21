import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'firebase_service.dart';
import '../../models/pending_reading_model.dart';

class SyncService {
  static void startListening() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        await _syncPendingData();
      }
    });
  }

  static Future<void> _syncPendingData() async {
    final box = Hive.box('pendingUploads');
    if (box.isEmpty) return;

    print("🔄 Syncing ${box.length} pending readings");

    final items = box.values.toList();
    box.clear();

    for (final item in items) {
      final pending = PendingReading.fromJson(
        Map<String, dynamic>.from(item),
      );
      await FirebaseService().saveReading(
        pending.mac,
        pending.data,
      );
    }
  }
}



//This file is the automatic delivery system.
//
// 🔴 Problem it solves
//
// Internet goes OFF → data stored locally
//
// Internet comes back → how do we upload automatically?
//
// 👉 This file listens to network changes and syncs data.