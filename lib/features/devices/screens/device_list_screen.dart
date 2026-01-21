import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/ble/ble_service.dart';
import 'device_connect_screen.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final BleService _bleService = BleService();
  final List<DiscoveredDevice> _devices = [];

  StreamSubscription<DiscoveredDevice>? _scanSub;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndScan();
  }

  // 🔐 Permission + Scan
  Future<void> _requestPermissionAndScan() async {
    final status = await Permission.locationWhenInUse.request();

    if (!status.isGranted) {
      _showPermissionError();
      return;
    }

    _startScan();
  }

  // 🔍 BLE Scan
  void _startScan() {
    _isScanning = true;

    _scanSub = _bleService.scanDevices().listen(
          (device) {
        if (device.name.isEmpty) return;

        final exists = _devices.any((d) => d.id == device.id);
        if (!exists) {
          setState(() => _devices.add(device));
        }
      },
      onError: (e) {
        debugPrint("❌ Scan error: $e");
      },
    );
  }

  // 🛑 Stop scan
  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    _isScanning = false;
  }

  void _showPermissionError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Location permission required for BLE scan"),
      ),
    );
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Devices"),
        actions: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: _devices.isEmpty
          ? const Center(
        child: Text("Scanning for BLE devices..."),
      )
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];

          return ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(device.name),
            subtitle: Text(device.id),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _stopScan(); // 🛑 IMPORTANT

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DeviceConnectScreen(device: device),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
