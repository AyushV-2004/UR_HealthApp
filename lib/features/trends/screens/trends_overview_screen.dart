import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../trends_controller.dart';
import '../widgets/trends_toggle.dart';
import '../widgets/parameter_tabs.dart';
import '../widgets/trends_chart.dart';
import '../widgets/about_section.dart';
import '../widgets/time_range_selector.dart';

class TrendsOverviewScreen extends StatelessWidget {
  const TrendsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    final userId = user.uid;

    return ChangeNotifierProvider(
      create: (_) => TrendsController(),
      child: Consumer<TrendsController>(
        builder: (context, controller, _) {
          /// 🔐 Load device once
          if (controller.deviceId == null) {
            controller.loadUserDevice(userId);
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(23, 20, 23, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// =================================================
                    /// HEADER (matches Home screen flow)
                    /// =================================================
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Your History',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Environment',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          TrendsToggle(controller: controller),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// =================================================
                    /// PARAMETER CHIPS CONTAINER
                    /// (NO FIXED HEIGHT ❗)
                    /// =================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(24.89),
                      ),
                      child: ParameterTabs(controller: controller),
                    ),

                    const SizedBox(height: 12),

                    /// =================================================
                    /// TIME RANGE SELECTOR
                    /// =================================================
                    TimeRangeSelector(controller: controller),

                    const SizedBox(height: 20),

                    /// =================================================
                    /// GRAPH (exact Figma height)
                    /// =================================================
                    SizedBox(
                      height: 257,
                      width: double.infinity,
                      child: TrendsChart(
                        dataStream: controller.trendStream(
                          userId: userId,
                          deviceId: controller.deviceId!,
                        ),
                        threshold: controller.currentThreshold,
                        maxY: controller.maxY,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// =================================================
                    /// ABOUT SECTION
                    /// =================================================
                    const Text(
                      'About',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    AboutSection(mode: controller.mode),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
