import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';
import '../localization.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  String? _nameError;
  String? _emailError;

  String? _passwordError;

  bool _isLoading = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final event = data.event;
      if (session != null && (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed)) {
        final user = session.user;
        
        AppState.userId = user.id.hashCode;
        AppState.userEmail = user.email;
        final String nameMeta = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '';
        AppState.userName = nameMeta.isNotEmpty ? nameMeta : (user.email?.split('@')[0] ?? 'User');
        AppState.userPassword = '';
        
        await AppState.saveUserInfo();
        
        try {
          await Supabase.instance.client.from('profiles').upsert({
            'id': user.id,
            'email': user.email,
            'display_name': nameMeta,
          });
        } catch (e) {
          debugPrint('Profiles table upsert skipped or failed: $e');
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  void _createAccount() async {
    setState(() {
      _nameError =
          _nameCtrl.text.trim().isEmpty ? 'you must enter the Name'.tr : null;

      final emailText = _emailCtrl.text.trim();
      if (emailText.isEmpty) {
        _emailError = 'you must enter the Email'.tr;
      } else if (!emailText.contains('@')) {
        _emailError = 'Please enter a valid email address'.tr;
      } else {
        _emailError = null;
      }


      _passwordError = _passwordCtrl.text.trim().isEmpty
          ? 'you must enter the Password'.tr
          : null;
    });

    if (_nameError == null &&
        _emailError == null &&

        _passwordError == null) {
      setState(() => _isLoading = true);
      try {
        final data = await ApiService.signup(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );
        
        AppState.userId = data["user_id"];
        AppState.userEmail = data["email"] ?? _emailCtrl.text.trim();
        AppState.userName = data["name"] ?? _nameCtrl.text.trim();
        AppState.userPassword = _passwordCtrl.text.trim();
        await AppState.saveUserInfo();
        
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();

    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Safespace'.tr,
                      style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                Text(
                  'Create account'.tr,
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                _buildField(
                  controller: _nameCtrl,
                  hint: 'Name'.tr,
                  icon: Icons.person_outline,
                  errorText: _nameError,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  hint: 'Email'.tr,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),

                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordCtrl,
                  hint: 'Password'.tr,
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  errorText: _passwordError,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.textDimmed,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Create Account'.tr),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Google Sign-Up Button ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      foregroundColor: AppTheme.textWhite,
                      side: BorderSide(color: AppTheme.accentPurple.withOpacity(0.3), width: 1),
                    ),
                    onPressed: () async {
                      try {
                        await Supabase.instance.client.auth.signInWithOAuth(
                          OAuthProvider.google,
                          redirectTo: 'io.supabase.flutter://login-callback',
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.login, size: 20),
                    label: Text('Continue with Google'.tr),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'.tr,
                        style:
                            TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signin'),
                      child: Text(
                        'Sign In'.tr,
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        errorStyle: TextStyle(color: AppTheme.red),
        prefixIcon: Icon(icon, color: AppTheme.textDimmed, size: 20),
        suffixIcon: suffix,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.red, width: 1.5),
        ),
      ),
    );
  }
}
