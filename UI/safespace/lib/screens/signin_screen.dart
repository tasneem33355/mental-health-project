import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../data/app_state.dart';
import '../services/api_service.dart';
import '../localization.dart';

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

  void _login() async {
    setState(() {
      final emailText = _emailCtrl.text.trim();
      if (emailText.isEmpty) {
        _emailError = 'you must enter the Email'.tr;
      } else if (!emailText.contains('@')) {
        _emailError = 'Please enter a valid email address'.tr;
      } else {
        _emailError = null;
      }
      
      _passwordError = _passwordCtrl.text.trim().isEmpty ? 'you must enter the Password'.tr : null;
    });

    if (_emailError == null && _passwordError == null) {
      setState(() => _isLoading = true);
      try {
        final data = await ApiService.login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text.trim(),
        );
        
        AppState.userId = data["user_id"];
        AppState.userEmail = data["email"] ?? _emailCtrl.text.trim();
        AppState.userName = data["name"] ?? AppState.userEmail!.split('@')[0];
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

  void _forgotPassword() async {
    final emailText = _emailCtrl.text.trim();
    if (emailText.isEmpty || !emailText.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email to reset password'.tr;
      });
      return;
    }
    
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(emailText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to your email'.tr), backgroundColor: AppTheme.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
                const SizedBox(height: 48),

                Text(
                  'Login'.tr,
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
                  style: TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Email'.tr,
                    errorText: _emailError,
                    errorStyle: TextStyle(color: AppTheme.red),
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.textDimmed, size: 20),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  style: TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Password'.tr,
                    errorText: _passwordError,
                    errorStyle: TextStyle(color: AppTheme.red),
                    prefixIcon: Icon(Icons.lock_outline,
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
                      borderSide: BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: Text(
                      'Forgot Password?'.tr,
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
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Login'.tr),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Google Sign-In Button ---
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
                    Text("Don't have an account?".tr,
                        style:
                            TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signup'),
                      child: Text(
                        'Sign Up'.tr,
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

}
