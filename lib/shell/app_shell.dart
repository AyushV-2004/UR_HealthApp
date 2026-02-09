import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ur_health/features/home/screens/home_dashboard_screen.dart';
import 'package:ur_health/features/trends/screens/trends_overview_screen.dart';
import 'package:ur_health/features/profile/screens/profile_screen.dart';
import 'package:ur_health/app/widgets/ur_bottom_nav_bar.dart';
import 'package:ur_health/shell/widgets/sync_now_fab.dart';
import '../features/health/screens/ur_health_screen.dart';
import '../services/ble/ble_device_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}
//
// class _AppShellState extends State<AppShell> {
//   int _currentIndex = 0;
//
//   final List<Widget> _screens = const [
//     HomeDashboardScreen(),
//     TrendsOverviewScreen(),
//     UrHealthScreen(), // UrHealth (later)
//     ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: UrBottomNavBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//       ),
//     );
//   }
// }
class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final deviceProvider = context.watch<BleDeviceProvider>();

    // 🔥 Auto-switch to Home when device is set
    if (deviceProvider.hasDevice && _currentIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentIndex = 0);
      });
    }
  }

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    TrendsOverviewScreen(),
    UrHealthScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const SyncNowFAB(),
      bottomNavigationBar: UrBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
