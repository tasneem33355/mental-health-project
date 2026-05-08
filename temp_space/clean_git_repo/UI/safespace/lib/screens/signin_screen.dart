import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  String? _emailError;
  String? _passwordError;

  void _login() {
    setState(() {
      final emailText = _emailCtrl.text.trim();
      if (emailText.isEmpty) {
        _emailError = 'you must enter the Email';
      } else if (!emailText.endsWith('@gmail.com')) {
        _emailError = 'Email must end with @gmail.com';
      } else {
        _emailError = null;
      }
      
      _passwordError = _passwordCtrl.text.trim().isEmpty ? 'you must enter the Password' : null;
    });

    if (_emailError == null && _passwordError == null) {
      AppState.userPassword = _passwordCtrl.text;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A3E), AppTheme.bgDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.accentPurple.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.shield_outlined,
                          color: AppTheme.accentPurple, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Safespace',
                      style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                const Text(
                  'Login',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Email or Phone Number',
                    errorText: _emailError,
                    errorStyle: const TextStyle(color: AppTheme.red),
                    prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textDimmed, size: 20),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    errorText: _passwordError,
                    errorStyle: const TextStyle(color: AppTheme.red),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textDimmed, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textDimmed,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.accentPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppTheme.textDimmed, height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or',
                          style: TextStyle(
                              color: AppTheme.textDimmed, fontSize: 13)),
                    ),
                    const Expanded(
                        child: Divider(color: AppTheme.textDimmed, height: 1)),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton('G', const Color(0xFFEA4335)),
                    const SizedBox(width: 16),
                    _socialButton('f', const Color(0xFF1877F2)),
                    const SizedBox(width: 16),
                    _socialButton('', const Color(0xFF555555),
                        icon: Icons.apple),
                  ],
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style:
                            TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppTheme.accentPurple,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String label, Color color, {IconData? icon}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.textDimmed.withOpacity(0.3)),
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 22)
            : Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
      ),
    );
  }
}
