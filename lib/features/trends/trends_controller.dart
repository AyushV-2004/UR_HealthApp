// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// enum TrendMode { air, heat }
// enum TimeRange { hour1, hour24, day7 }
//
// /// =======================
// /// THRESHOLD MODEL
// /// =======================
// class MetricThreshold {
//   final double green;
//   final double yellow;
//   final double red;
//
//   const MetricThreshold({
//     required this.green,
//     required this.yellow,
//     required this.red,
//   });
// }
//
// class TrendsController extends ChangeNotifier {
//   /// ========================
//   /// MODE (Air / Heat)
//   /// ========================
//   TrendMode _mode = TrendMode.air;
//   TrendMode get mode => _mode;
//
//   /// ========================
//   /// SELECTED PARAMETER
//   /// ========================
//   String _selectedParameter = 'PM2.5';
//   String get selectedParameter => _selectedParameter;
//
//   /// ========================
//   /// TIME RANGE
//   /// ========================
//   TimeRange _range = TimeRange.hour1;
//   TimeRange get range => _range;
//
//   /// ========================
//   /// DEVICE ID (AUTO-FETCHED)
//   /// ========================
//   String? _deviceId;
//   String? get deviceId => _deviceId;
//
//   /// ========================
//   /// PARAMETERS BY MODE
//   /// ========================
//   List<String> get parameters =>
//       _mode == TrendMode.air
//           ? ['PM2.5', 'PM10', 'PM1']
//           : ['Heat Index', 'Temperature', 'Humidity', 'Noise'];
//
//   /// ========================
//   /// PARAMETER → FIRESTORE FIELD MAP
//   /// ========================
//   static const Map<String, String> parameterFieldMap = {
//     'PM2.5': 'pm25',
//     'PM10': 'pm10',
//     'PM1': 'pm1',
//     'Temperature': 'temperature',
//     'Humidity': 'humidity',
//     'Noise': 'noise',
//     'Heat Index': 'heatIndex', // future-ready
//   };
//
//   String get firestoreField =>
//       parameterFieldMap[_selectedParameter]!;
//
//   /// ========================
//   /// THRESHOLDS (GREEN / YELLOW / RED)
//   /// ========================
//   static const Map<String, MetricThreshold> thresholds = {
//     'pm25': MetricThreshold(green: 12, yellow: 35, red: 55),
//     'pm10': MetricThreshold(green: 50, yellow: 100, red: 250),
//     'pm1': MetricThreshold(green: 25, yellow: 50, red: 100),
//     'temperature': MetricThreshold(green: 30, yellow: 35, red: 40),
//     'humidity': MetricThreshold(green: 30, yellow: 60, red: 75),
//     'noise': MetricThreshold(green: 55, yellow: 70, red: 85),
//   };
//
//   MetricThreshold get currentThreshold {
//     // Heat Index is not stored yet → fallback safely
//     if (firestoreField == 'heatIndex') {
//       return thresholds['temperature']!;
//     }
//
//     return thresholds[firestoreField]!;
//   }
//
//   /// ========================
//   /// ACTIONS
//   /// ========================
//   void toggleMode(TrendMode mode) {
//     _mode = mode;
//     _selectedParameter = parameters.first;
//     notifyListeners();
//   }
//
//   void selectParameter(String param) {
//     _selectedParameter = param;
//     notifyListeners();
//   }
//
//   void setRange(TimeRange r) {
//     _range = r;
//     notifyListeners();
//   }
//
//   /// ========================
//   /// AUTO-FETCH DEVICE ID
//   /// ========================
//   Future<void> loadUserDevice(String userId) async {
//     if (_deviceId != null) return;
//
//     final snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('devices')
//         .limit(1)
//         .get();
//
//     if (snapshot.docs.isNotEmpty) {
//       _deviceId = snapshot.docs.first.id;
//       notifyListeners();
//     }
//   }
//
//   /// ========================
//   /// TIME RANGE → TIMESTAMP
//   /// ========================
//   int get startTimestamp {
//     final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//
//     switch (_range) {
//       case TimeRange.hour1:
//         return now - 3600;
//       case TimeRange.hour24:
//         return now - 86400;
//       case TimeRange.day7:
//         return now - 604800;
//     }
//   }
//
//   /// ========================
//   /// FIRESTORE → REALTIME STREAM
//   /// ========================
//   Stream<List<FlSpot>> trendStream({
//     required String userId,
//     required String deviceId,
//   }) {
//     final field = firestoreField;
//
//     return FirebaseFirestore.instance
//         .collection('users')
//         .doc(userId)
//         .collection('devices')
//         .doc(deviceId)
//         .collection('readings')
//         .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
//         .orderBy('timestamp')
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         final ts = (doc['timestamp'] as num).toDouble();
//         final value = (doc[field] as num).toDouble();
//         return FlSpot(ts, value);
//       }).toList();
//     });
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

/// =======================
/// ENUMS
/// =======================
enum TrendMode { air, heat }
enum TimeRange { hour1, hour24, day7 }

/// =======================
/// THRESHOLD MODEL
/// =======================
class MetricThreshold {
  final double green;
  final double yellow;
  final double red;

  const MetricThreshold({
    required this.green,
    required this.yellow,
    required this.red,
  });
}

class TrendsController extends ChangeNotifier {
  /// =================================================
  /// 🔁 DUMMY DATA TOGGLE
  /// =================================================
  bool useDummyData = true; // ❌ set false when backend ready

  /// =================================================
  /// MODE
  /// =================================================
  TrendMode _mode = TrendMode.air;
  TrendMode get mode => _mode;

  /// =================================================
  /// SELECTED PARAMETER
  /// =================================================
  String _selectedParameter = 'PM2.5';
  String get selectedParameter => _selectedParameter;

  /// =================================================
  /// TIME RANGE
  /// =================================================
  TimeRange _range = TimeRange.hour1;
  TimeRange get range => _range;

  /// =================================================
  /// DEVICE ID
  /// =================================================
  String? _deviceId;
  String? get deviceId => _deviceId;

  /// =================================================
  /// PARAMETERS BY MODE
  /// =================================================
  List<String> get parameters =>
      _mode == TrendMode.air
          ? ['PM2.5', 'PM10', 'PM1']
          : ['Heat Index', 'Temperature', 'Humidity', 'Noise'];

  /// =================================================
  /// PARAMETER → FIRESTORE FIELD
  /// =================================================
  static const Map<String, String> parameterFieldMap = {
    'PM2.5': 'pm25',
    'PM10': 'pm10',
    'PM1': 'pm1',
    'Temperature': 'temperature',
    'Humidity': 'humidity',
    'Noise': 'noise',
    'Heat Index': 'heatIndex',
  };

  String get firestoreField => parameterFieldMap[_selectedParameter]!;

  /// =================================================
  /// THRESHOLDS
  /// =================================================
  static const Map<String, MetricThreshold> thresholds = {
    'pm25': MetricThreshold(green: 12, yellow: 35, red: 55),
    'pm10': MetricThreshold(green: 50, yellow: 100, red: 250),
    'pm1': MetricThreshold(green: 25, yellow: 50, red: 100),
    'temperature': MetricThreshold(green: 30, yellow: 35, red: 40),
    'humidity': MetricThreshold(green: 30, yellow: 60, red: 75),
    'noise': MetricThreshold(green: 55, yellow: 70, red: 85),
  };

  MetricThreshold get currentThreshold {
    if (firestoreField == 'heatIndex') {
      return thresholds['temperature']!;
    }
    return thresholds[firestoreField]!;
  }

  /// =================================================
  /// DYNAMIC MAX Y (PER PARAMETER)
  /// =================================================
  double get maxY {
    switch (firestoreField) {
      case 'pm25':
        return 80;
      case 'pm10':
        return 300;
      case 'pm1':
        return 120;
      case 'temperature':
        return 45;
      case 'humidity':
        return 100;
      case 'noise':
        return 100;
      default:
        return currentThreshold.red + 10;
    }
  }

  /// =================================================
  /// ACTIONS
  /// =================================================
  void toggleMode(TrendMode mode) {
    _mode = mode;
    _selectedParameter = parameters.first;
    notifyListeners();
  }

  void selectParameter(String param) {
    _selectedParameter = param;
    notifyListeners();
  }

  void setRange(TimeRange r) {
    _range = r;
    notifyListeners();
  }

  /// =================================================
  /// LOAD DEVICE ID
  /// =================================================
  Future<void> loadUserDevice(String userId) async {
    if (_deviceId != null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('devices')
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      _deviceId = snapshot.docs.first.id;
      notifyListeners();
    }
  }

  /// =================================================
  /// TIME RANGE → TIMESTAMP
  /// =================================================
  int get startTimestamp {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    switch (_range) {
      case TimeRange.hour1:
        return now - 3600;
      case TimeRange.hour24:
        return now - 86400;
      case TimeRange.day7:
        return now - 604800;
    }
  }

  /// =================================================
  /// SAMPLE12 DUMMY DATA
  /// =================================================
  List<FlSpot> _generateSample12DummyData() {
    return const [
      FlSpot(0, 12),
      FlSpot(1, 18),
      FlSpot(2, 15),
      FlSpot(3, 22),
      FlSpot(4, 28),
      FlSpot(5, 25),
      FlSpot(6, 32),
      FlSpot(7, 38),
      FlSpot(8, 34),
      FlSpot(9, 40),
      FlSpot(10, 36),
      FlSpot(11, 42),
    ];
  }

  /// =================================================
  /// DATA STREAM
  /// =================================================
  Stream<List<FlSpot>> trendStream({
    required String userId,
    required String deviceId,
  }) {
    if (useDummyData) {
      return Stream.value(_generateSample12DummyData());
    }

    final field = firestoreField;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(deviceId)
        .collection('readings')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final ts = (doc['timestamp'] as num).toDouble();
        final value = (doc[field] as num).toDouble();
        return FlSpot(ts, value);
      }).toList();
    });
  }
}
