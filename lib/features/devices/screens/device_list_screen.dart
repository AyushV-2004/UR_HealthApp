import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../services/ble/ble_service.dart';
import '../../../services/ble/ble_connection_state.dart';
import '../../../services/ble/ble_device_provider.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final List<DiscoveredDevice> _devices = [];
  StreamSubscription<DiscoveredDevice>? _scanSub;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();

    final bleService = context.read<BleService>();

    _scanSub = bleService.scanDevices().listen((device) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleService = context.read<BleService>();
    final connectionState = context.read<BleConnectionState>();
    final deviceProvider = context.read<BleDeviceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Available Devices")),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (_, i) {
          final device = _devices[i];

          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id),
            onTap: () async {
              _stopScan();
              final bleService = context.read<BleService>();
              final connectionState = context.read<BleConnectionState>();
              final deviceProvider = context.read<BleDeviceProvider>();
    deviceProvider.setDevice(device.id);

    await bleService.connect(device.id, connectionState);

    while (!connectionState.isConnected) {
    await Future.delayed(const Duration(milliseconds: 200));
    }

                // 4️⃣ Navigate only after connected
                if (!mounted) return;
                Navigator.pop(context);
              },
          );
        },
      ),
    );
  }
}