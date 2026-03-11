//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class FirebaseService {
//   final FirebaseFirestore _firestore =
//       FirebaseFirestore.instance;
//   final FirebaseAuth _auth =
//       FirebaseAuth.instance;
//
//   /// 🔗 Update device connection & metadata
//   Future<void> updateDeviceStatus({
//     required String mac,
//     required bool isConnected,
//     required String location,
//     String deviceName = "UrHealth Air Monitor",
//   }) async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;
//
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('devices')
//         .doc(mac)
//         .set({
//       'macAddress': mac,
//       'deviceName': deviceName,
//       'location': location,
//       'isConnected': isConnected,
//       'lastSeen': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }
//
//   /// 🔄 LEGACY METHOD (single reading stream flow)
//   Future<void> saveReading(
//       String mac,
//       Map<String, dynamic> data,
//       ) async {
//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;
//
//     final deviceRef = _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('devices')
//         .doc(mac);
//
//     final DateTime timestamp = data['timestamp'];
//
//     final docId =
//     timestamp.toUtc().toIso8601String();
//
//     // ✅ Update latest snapshot (for HomeDashboard)
//     await deviceRef.set({
//       'readings': {
//         ...data,
//         'timestamp':
//         Timestamp.fromDate(timestamp.toUtc()),
//       },
//       'lastSeen': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//
//     // ✅ Save historical reading with timestamp as ID
//     await deviceRef
//         .collection('readings')
//         .doc(docId)
//         .set({
//       ...data,
//       'timestamp':
//       Timestamp.fromDate(timestamp.toUtc()),
//     });
//   }
//
//   /// 🔄 Batch save readings (Sync Now flow)
//   Future<void> batchSaveReadings({
//     required String uid,
//     required String mac,
//     required List<Map<String, dynamic>> readings,
//   }) async {
//     final batch = _firestore.batch();
//
//     final deviceRef = _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('devices')
//         .doc(mac);
//
//     for (final reading in readings) {
//       final DateTime timestamp =
//       reading['timestamp'];
//
//       final docId =
//       timestamp.toUtc().toIso8601String();
//
//       final docRef = deviceRef
//           .collection('readings')
//           .doc(docId);
//
//       batch.set(docRef, {
//         ...reading,
//         'timestamp':
//         Timestamp.fromDate(timestamp.toUtc()),
//       });
//     }
//
//     await batch.commit();
//
//     print(
//         "✅ Batch saved ${readings.length} readings");
//   }
//
//   /// 🕒 Update sync metadata
//   Future<void> updateLastSync(
//       String uid,
//       String mac,
//       ) async {
//     await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('devices')
//         .doc(mac)
//         .set({
//       'lastSyncAt':
//       FieldValue.serverTimestamp(),
//       'lastSeen':
//       FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }
// }








import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

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

  /// 🔄 LEGACY METHOD (single reading stream flow)
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

    final DateTime timestamp = data['timestamp'];

    final docId = timestamp.toUtc().toIso8601String();

    // ✅ Update latest snapshot (for HomeDashboard)
    await deviceRef.set({
      'readings': {
        ...data,
        'timestamp':
        Timestamp.fromDate(timestamp.toUtc()),
      },
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ⚠ Historical save (kept legacy behavior)
    await deviceRef
        .collection('readings')
        .doc(docId)
        .set({
      ...data,
      'timestamp':
      Timestamp.fromDate(timestamp.toUtc()),
    });
  }

  /// 🔥 Batch save readings (Sync Now flow) — FIXED
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

    print("☁ Preparing batch write...");

    for (int i = 0; i < readings.length; i++) {
      final reading = readings[i];
      final DateTime timestamp = reading['timestamp'];

      // ✅ Unique ID prevents overwrite
      final docId =
          '${timestamp.toUtc().microsecondsSinceEpoch}_$i';

      final docRef = deviceRef
          .collection('readings')
          .doc(docId);

      print("📝 Writing docId: $docId");

      batch.set(docRef, {
        ...reading,
        'timestamp':
        Timestamp.fromDate(timestamp.toUtc()),
      });
    }

    await batch.commit();

    print(
        "🔥 Batch committed: ${readings.length} docs");
  }

  /// 🕒 Update sync metadata
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
      'lastSyncAt':
      FieldValue.serverTimestamp(),
      'lastSeen':
      FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

