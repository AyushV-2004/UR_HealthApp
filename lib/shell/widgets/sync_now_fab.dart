import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ble/ble_device_provider.dart';
import '../../services/sync/sync_service.dart';
import '../../services/sync/sync_progress.dart';

class SyncNowFAB extends StatelessWidget {
  const SyncNowFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<BleDeviceProvider>();
    final syncProgress = context.watch<SyncProgress>();
    final syncService = context.read<SyncService>();

    // ❌ No device selected → hide button
    if (!deviceProvider.hasDevice) {
      return const SizedBox.shrink();
    }

    String label;
    Widget icon;

    switch (syncProgress.stage) {
      case SyncStage.connecting:
        label = "Connecting...";
        icon = const CircularProgressIndicator(strokeWidth: 2);
        break;

      case SyncStage.fetching:
        label = "Fetching data...";
        icon = const CircularProgressIndicator(strokeWidth: 2);
        break;

      case SyncStage.uploading:
        label = "Uploading...";
        icon = const CircularProgressIndicator(strokeWidth: 2);
        break;

      case SyncStage.success:
        label = "Synced";
        icon = const Icon(Icons.check);
        break;

      case SyncStage.failure:
        label = "Retry Sync";
        icon = const Icon(Icons.error);
        break;

      case SyncStage.idle:
      default:
        label = "Sync Now";
        icon = const Icon(Icons.sync);
    }

    return FloatingActionButton.extended(
      onPressed: syncProgress.isSyncing
          ? null
          : () {
        syncService.syncNow(
          mac: deviceProvider.mac!,
        );
      },
      icon: SizedBox(
        width: 18,
        height: 18,
        child: Center(child: icon),
      ),
      label: Text(label),
    );
  }
}
