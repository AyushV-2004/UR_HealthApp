import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static Stream<QuerySnapshot> readingsStream(String mac) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(mac)
        .collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();
  }
  static Stream<QuerySnapshot> devicesStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .snapshots();
  }

}
