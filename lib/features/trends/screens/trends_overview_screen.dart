import 'package:flutter/material.dart';

class TrendsOverviewScreen extends StatelessWidget {
  const TrendsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Trends Overview',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
