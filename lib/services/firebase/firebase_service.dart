import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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

  // 🔥 REQUIRED METHOD (this fixes the error)
  Future<void> saveReading(
      String mac,
      Map<String, dynamic> data,
      ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac)
        .collection('readings')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
