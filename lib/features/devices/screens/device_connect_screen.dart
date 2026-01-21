import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../../../services/ble/ble_service.dart';
import '../../../services/ble/ble_constants.dart';
import '../../../services/ble/ble_parser.dart';
import '../../../services/ble/ble_connection_state.dart';
import '../../../services/ble/ble_device_provider.dart';
import '../../../services/ble/ble_data_provider.dart';

class DeviceConnectScreen extends StatefulWidget {
  final DiscoveredDevice device;

  const DeviceConnectScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceConnectScreen> createState() =>
      _DeviceConnectScreenState();
}

class _DeviceConnectScreenState
    extends State<DeviceConnectScreen> {
  final BleService _bleService = BleService();
  StreamSubscription<List<int>>? _dataSub;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    final connectionState =
    context.read<BleConnectionState>();
    final deviceProvider =
    context.read<BleDeviceProvider>();
    final dataProvider =
    context.read<BleDataProvider>();

    // Save connected device
    deviceProvider.setMac(widget.device.id);

    // Connect BLE
    _bleService.connect(
      widget.device.id,
      connectionState,
    );

    // Subscribe to data
    _dataSub = _bleService
        .subscribeToData()
        .listen((raw) {
      BleParser.parse(
        raw,
        dataProvider,
        mac: widget.device.id,
      );
    });

    // Request last data
    _bleService.writeCommand(
      BleConstants.getLastDataCommand,
    );
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Consumer2<BleConnectionState, BleDataProvider>(
        builder: (context, connection, data, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  connection.isConnected
                      ? "🟢 Connected"
                      : "🔴 Connecting...",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                _info("Temperature", "${data.temperature} °C"),
                _info("Humidity", "${data.humidity} %"),
                _info("PM 2.5", "${data.pm25}"),
                _info("PM 10", "${data.pm10}"),
                _info("Noise", "${data.noise} dB"),
                _info("Battery", "${data.battery}%"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
