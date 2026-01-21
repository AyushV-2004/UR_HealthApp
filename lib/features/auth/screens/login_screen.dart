import 'package:flutter/material.dart';
import '../../../services/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              /// 🔤 Title
              const Text(
                "Log In",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF282828),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Enter your email and password to securely\naccess your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF4F4F50),
                ),
              ),

              const SizedBox(height: 32),

              /// 📧 Email
              _InputField(
                controller: _emailCtrl,
                hint: "Email Address",
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

              const SizedBox(height: 8),

              /// Remember / Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "○ Remember me",
                    style: TextStyle(
                      fontSize: 8,
                      fontFamily: 'Poppins',
                      color: Color(0xFF4F4F50),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Forgot password screen
                    },
                    child: const Text(
                      "Forgot password",
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'Poppins',
                        color: Color(0xFF4F4F50),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🔘 Login Button
              SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton(
                  onPressed: loading ? null : _login,
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
                    "Login",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF282828),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "By clicking Login, you agree to our\nTerms, Data Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'Poppins',
                  color: Color(0xFF4F4F50),
                ),
              ),

              const SizedBox(height: 24),

              /// 👉 Register Redirect
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF282828),
                  ),
                  children: [
                    const TextSpan(text: "Don’t have an account? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Sign Up here",
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

              /// 🔵 Google Login
              GestureDetector(
                onTap: _googleLogin,
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

  /// 🔐 Email/Password Login
  Future<void> _login() async {
    setState(() => loading = true);

    final user = await _authService.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    setState(() => loading = false);

    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// 🔑 Google Login
  Future<void> _googleLogin() async {
    final user = await _authService.signInWithGoogle();

    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
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
