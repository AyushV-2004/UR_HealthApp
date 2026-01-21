import 'package:flutter/material.dart';
import 'package:ur_health/features/home/screens/home_dashboard_screen.dart';
import 'package:ur_health/features/trends/screens/trends_overview_screen.dart';
import 'package:ur_health/features/profile/screens/profile_screen.dart';
import 'package:ur_health/app/widgets/ur_bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    TrendsOverviewScreen(),
    Placeholder(), // UrHealth (later)
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: UrBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
