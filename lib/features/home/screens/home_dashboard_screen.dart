import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/exposure_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/environment_section.dart';
import '../widgets/checkin_card.dart';

class HomeDashboardScreen  extends StatelessWidget {
  const HomeDashboardScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 16),
              ExposureCard(),
              SizedBox(height: 16),
              AlertCard(),
              SizedBox(height: 24),
              Text(
                "Environment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              EnvironmentSection(),
              SizedBox(height: 24),
              CheckInCard(),
            ],
          ),
        ),
      ),
    );
  }
}
