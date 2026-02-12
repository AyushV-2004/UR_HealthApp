import 'package:flutter/material.dart';

// Widgets
import '../widgets/ur_health_header.dart';
import '../widgets/exposure_summary_text.dart';
import '../widgets/environment_context_card.dart';
import '../widgets/weekly_insight_card.dart';
import '../widgets/health_stat_card.dart';

class UrHealthScreen extends StatefulWidget {
  const UrHealthScreen({super.key});

  @override
  State<UrHealthScreen> createState() => _UrHealthScreenState();
}

class _UrHealthScreenState extends State<UrHealthScreen> {
  // 🔮 These will later come from API / device / state management
  final int symptomsReported = 3;
  final String bestDay = "Wednesday";
  final String mostCommonSymptom = "Fatigue";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              /// Header
              UrHealthHeader(),

              SizedBox(height: 24),

              /// Exposure summary text
              ExposureSummaryText(),

              SizedBox(height: 16),

              /// Environment Context card
              EnvironmentContextCard(),

              SizedBox(height: 20),

              /// Weekly Insight card
              WeeklyInsightCard(),

              SizedBox(height: 24),

              /// Stats Cards
              HealthStatCard(
                title: "Symptoms Reported",
                value: "3",
                badgeText: "-2 from last week",
                badgeBgColor: Color(0xFFE6FFF2),
                badgeTextColor: Color(0xFF1DBF73),
              ),

              SizedBox(height: 16),

              HealthStatCard(
                title: "Best Day",
                value: "Wednesday",
                badgeText: "No Symptoms",
                badgeBgColor: Color(0xFFE6FFF2),
                badgeTextColor: Color(0xFF1DBF73),
              ),

              SizedBox(height: 16),

              HealthStatCard(
                title: "Most Common",
                value: "Fatigue",
                badgeText: "Reported 4 times",
                badgeBgColor: Color(0xFFFFF3E0),
                badgeTextColor: Color(0xFFFF9800),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
