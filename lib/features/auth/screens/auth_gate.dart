import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shell/app_shell.dart';
import '../../home/screens/home_dashboard_screen.dart';
import '../../auth/screens/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Logged in
        if (snapshot.hasData) {
          return const AppShell(); // or AppShell
        }

        // ❌ Not logged in
        return const LoginOrRegister();
      },
    );
  }
}
