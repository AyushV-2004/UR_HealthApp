import 'package:flutter/material.dart';
import 'login_screen.dart';

class LoginOrRegister extends StatelessWidget {
  const LoginOrRegister({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 NO FirebaseAuth logic here
    return const LoginScreen();
  }
}
