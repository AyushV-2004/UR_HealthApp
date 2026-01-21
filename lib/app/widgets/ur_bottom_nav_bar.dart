import 'package:flutter/material.dart';
class UrBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const UrBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  Widget _navIcon(String asset, bool active) {
    return Image.asset(
      asset,
      height: 24,
      width: 24,
      color: active ? null : Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFDFD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/home_inactive.png'),
              ),
            ),
            activeIcon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/home_active.png'),
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/trends_inactive.png'),
              ),
            ),
            activeIcon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/trends_active.png'),
              ),
            ),
            label: 'UrTrends',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/health_inactive.png'),
              ),
            ),
            activeIcon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/health_active.png'),
              ),
            ),
            label: 'UrHealth',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/profile_inactive.png'),
              ),
            ),
            activeIcon: SizedBox(
              height: 24,
              child: Image(
                image: AssetImage('assets/icons/navigation/profile_active.png'),
              ),
            ),
            label: 'UrProfile',
          ),
        ],
      ),
    );
  }
}
