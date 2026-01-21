import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/auth/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),

              /// 🔤 Title
              const Text(
                "Create Account",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF282828),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Create a new account to get started and enjoy\nseamless access to our features.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF262D37),
                ),
              ),

              const SizedBox(height: 32),

              /// 👤 Name
              _InputField(
                controller: _nameCtrl,
                hint: "Name",
              ),

              const SizedBox(height: 20),

              /// 📧 Email
              _InputField(
                controller: _emailCtrl,
                hint: "Email address",
              ),

              const SizedBox(height: 20),

              /// 🔒 Password
              _InputField(
                controller: _passwordCtrl,
                hint: "Password",
                obscureText: obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 🔒 Confirm Password
              _InputField(
                controller: _confirmPasswordCtrl,
                hint: "Confirm Password",
                obscureText: obscureConfirmPassword,
                suffix: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() =>
                    obscureConfirmPassword = !obscureConfirmPassword);
                  },
                ),
              ),

              const SizedBox(height: 24),

              /// 🔘 Create Account Button
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: loading ? null : _register,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5F6FF),
                    side: const BorderSide(color: Color(0xFF66CCFF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    "Create Account",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF282828),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "By clicking Sign up, you agree to our\nTerms, Data Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'Poppins',
                  color: Color(0xFF4F4F50),
                ),
              ),

              const SizedBox(height: 24),

              /// 🔁 Login Redirect
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF282828),
                  ),
                  children: [
                    const TextSpan(text: "Already have an account? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // back to login
                        },
                        child: const Text(
                          "Sign In here",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF66CCFF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Divider(),

              const SizedBox(height: 16),

              const Text(
                "Or Continue With Account",
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  color: Color(0xFF4F4F50),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔵 Google Sign-Up
              GestureDetector(
                onTap: _googleRegister,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 0.3),
                  ),
                  child: Image.asset(
                    'assets/icons/google.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔐 Email Signup + Firestore
  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showError("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    final user = await _authService.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (user != null) {
      await _saveUserProfile(
        uid: user.uid,
        name: _nameCtrl.text.trim(),
        email: user.email!,
        provider: 'email',
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/app');
      }
    }

    setState(() => loading = false);
  }

  /// 🔑 Google Signup + Firestore
  Future<void> _googleRegister() async {
    final user = await _authService.signInWithGoogle();

    if (user != null) {
      await _saveUserProfile(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email!,
        provider: 'google',
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  /// 📦 Save user in Firestore
  Future<void> _saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String provider,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'provider': provider,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}


class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: suffix,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF90969E)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF66CCFF)),
          ),
        ),
      ),
    );
  }
}
