import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../services/ble/ble_service.dart';
import '../../../services/ble/ble_constants.dart';
import '../../../services/ble/ble_connection_state.dart';
import '../../../services/ble/ble_device_provider.dart';
import '../../../services/ble/ble_data_provider.dart';


class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final BleService _bleService = BleService();
  final List<DiscoveredDevice> _devices = [];

  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<DeviceConnectionState>? _connectSub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    _scanSub = _bleService.scanDevices().listen((device) {
      if (device.name.isEmpty) return;
      if (_devices.any((d) => d.id == device.id)) return;

      setState(() => _devices.add(device));
    });
  }

  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _connectSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Devices")),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (_, i) {
          final device = _devices[i];

          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id),
            onTap: () {
              _stopScan();

              final connectionState =
              context.read<BleConnectionState>();
              final deviceProvider =
              context.read<BleDeviceProvider>();
              final dataProvider =
              context.read<BleDataProvider>();

              // ✅ GLOBAL BLE CONTEXT (IMPORTANT)
              BleConstants.connectedDeviceId = device.id;

              // ✅ UI + FIRESTORE CONTEXT
              deviceProvider.setMac(device.id);

              _connectSub = _bleService
                  .connect(device.id, connectionState)
                  .listen((state) {
                if (state == DeviceConnectionState.connected) {
                  // ✅ START OLD-SAFE POLLING
                  onTap: () {
                    _stopScan();

                    final connectionState =
                    context.read<BleConnectionState>();
                    final deviceProvider =
                    context.read<BleDeviceProvider>();

                    // ✅ GLOBAL BLE CONTEXT
                    BleConstants.connectedDeviceId = device.id;

                    // ✅ STORE MAC FOR APP
                    deviceProvider.setMac(device.id);

                    _connectSub = _bleService
                        .connect(device.id, connectionState)
                        .listen((state) {
                      if (state == DeviceConnectionState.connected) {
                        if (!mounted) return;
                        Navigator.pop(context); // back to AppShell
                      }
                    });
                  };
                if (!mounted) return;
                  Navigator.pop(context); // back to AppShell
          ;      }
              });
            },
          );
        },
      ),
    );
  }
}
