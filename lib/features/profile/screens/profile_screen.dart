import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/profile_card.dart';
import '../widgets/device_status_card.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_tile.dart';
import '../widgets/switch_tile.dart';

import '../../devices/screens/device_list_screen.dart';
import '../../../services/ble/ble_connection_state.dart';
import '../../../services/ble/ble_device_provider.dart';
import '../../../services/ble/ble_data_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dailyReminder = true;
  bool doNotDisturb = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "UrProfile",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              ProfileCard(
                name: "Hari Krish",
                email: "harikrish@gmail.com",
                onTap: () {},
              ),

              const SizedBox(height: 12),

              /// 🔗 DEVICE STATUS (LIVE BLE)
              Consumer2<BleConnectionState, BleDataProvider>(
                builder: (context, connection, data, _) {
                  if (!connection.isConnected) {
                    return const DeviceStatusCard(
                      deviceName: "UrHealth Air Monitor",
                      status: "Not Connected",
                    );
                  }

                  return DeviceStatusCard(
                    deviceName: "UrHealth Air Monitor",
                    status:
                    "Connected  •  Battery ${data.battery.toInt()}%",
                  );
                },
              ),

              const SizedBox(height: 24),
              const SectionTitle(text: "PERSONAL"),

              SettingsTile(
                title: "Personal Information",
                subtitle: "Name, age, health conditions",
                onTap: () {},
              ),
              SettingsTile(
                title: "Units & Preferences",
                subtitle: "Metric, Fahrenheit, etc.",
                onTap: () {},
              ),

              const SizedBox(height: 24),
              const SectionTitle(text: "DEVICES"),

              /// 🔗 CONNECTED DEVICES TILE (LIVE BLE)
              Consumer2<BleConnectionState, BleDeviceProvider>(
                builder: (context, connection, device, _) {
                  return SettingsTile(
                    title: "Connected Devices",
                    subtitle: connection.isConnected
                        ? "Connected • ${device.mac ?? 'UrHealth Air Monitor'}"
                        : "Not connected",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceListScreen(),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
              const SectionTitle(text: "NOTIFICATIONS"),

              SwitchTile(
                title: "Daily Check-in Reminder",
                value: dailyReminder,
                onChanged: (v) =>
                    setState(() => dailyReminder = v),
              ),
              SwitchTile(
                title: "Do Not Disturb",
                value: doNotDisturb,
                onChanged: (v) =>
                    setState(() => doNotDisturb = v),
              ),

              const SizedBox(height: 24),
              const SectionTitle(text: "PRIVACY & SUPPORT"),

              SettingsTile(
                title: "Privacy & Data",
                subtitle: "Manage Your Data",
                onTap: () {},
              ),
              SettingsTile(
                title: "Language",
                subtitle: "English",
                onTap: () {},
              ),
              SettingsTile(
                title: "Help & Support",
                subtitle: "",
                onTap: () {},
              ),

              const SizedBox(height: 30),
              const Center(
                child: Text(
                  "UrHealth v1.0.0",
                  style:
                  TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
