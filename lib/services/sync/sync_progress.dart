import 'package:flutter/material.dart';

enum SyncStage {
  idle,
  connecting,
  fetching,
  uploading,
  success,
  failure,
}

class SyncProgress extends ChangeNotifier {
  SyncStage _stage = SyncStage.idle;
  String? _error;

  SyncStage get stage => _stage;
  String? get error => _error;

  bool get isSyncing =>
      _stage == SyncStage.connecting ||
          _stage == SyncStage.fetching ||
          _stage == SyncStage.uploading;

  void setStage(SyncStage stage) {
    _stage = stage;
    _error = null;
    notifyListeners();
  }

  void setError(String message) {
    _stage = SyncStage.failure;
    _error = message;
    notifyListeners();
  }

  void reset() {
    _stage = SyncStage.idle;
    _error = null;
    notifyListeners();
  }
}
