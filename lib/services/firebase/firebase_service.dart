import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔗 Update device connection & metadata
  Future<void> updateDeviceStatus({
    required String mac,
    required bool isConnected,
    required String location,
    String deviceName = "UrHealth Air Monitor",
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac)
        .set({
      'macAddress': mac,
      'deviceName': deviceName,
      'location': location,
      'isConnected': isConnected,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ⚠️ LEGACY METHOD (streaming-based, kept for safety)
  /// Used by old flow, NOT used by SyncService
  Future<void> saveReading(
      String mac,
      Map<String, dynamic> data,
      ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final deviceRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac);

    // ✅ Update latest snapshot (Home screen uses this)
    await deviceRef.set({
      'readings': {
        ...data,
        'timestamp': FieldValue.serverTimestamp(),
      },
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ✅ Save single historical reading
    await deviceRef.collection('readings').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 🔄 NEW: Batch save readings (Sync Now flow)
  Future<void> batchSaveReadings({
    required String uid,
    required String mac,
    required List<Map<String, dynamic>> readings,
  }) async {
    final batch = _firestore.batch();

    final deviceRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac);

    for (final reading in readings) {
      final docRef = deviceRef.collection('readings').doc();

      batch.set(docRef, {
        ...reading,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// 🕒 NEW: Update sync metadata
  Future<void> updateLastSync(
      String uid,
      String mac,
      ) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac)
        .set({
      'lastSyncAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
