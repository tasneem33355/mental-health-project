import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import '../main.dart';
import '../data/app_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  void _createAccount() {
    setState(() {
      _nameError = _nameCtrl.text.trim().isEmpty ? 'you must enter the Name' : null;
      
      final emailText = _emailCtrl.text.trim();
      if (emailText.isEmpty) {
        _emailError = 'you must enter the Email';
      } else if (!emailText.endsWith('@gmail.com')) {
        _emailError = 'Email must end with @gmail.com';
      } else {
        _emailError = null;
      }

      _phoneError = _phoneCtrl.text.trim().isEmpty ? 'you must enter the Phone Number' : null;
      _passwordError = _passwordCtrl.text.trim().isEmpty ? 'you must enter the Password' : null;
    });

    if (_nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null) {
      AppState.userPassword = _passwordCtrl.text;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
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
                const SizedBox(height: 36),

                const Text(
                  'Create account',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),

                _buildField(
                  controller: _nameCtrl,
                  hint: 'Name',
                  icon: Icons.person_outline,
                  errorText: _nameError,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 14),
                IntlPhoneField(
                  controller: _phoneCtrl,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  dropdownTextStyle: const TextStyle(color: AppTheme.textWhite, fontSize: 10),
                  showDropdownIcon: true,
                  dropdownIcon: const Icon(Icons.arrow_drop_down, color: AppTheme.textDimmed, size: 12),
                  flagsButtonPadding: const EdgeInsets.only(left: 4, right: 0),
                  showCountryFlag: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: const TextStyle(color: AppTheme.textDimmed, fontSize: 13),
                    counterText: '',
                    errorText: _phoneError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    errorStyle: const TextStyle(color: AppTheme.red),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
                    ),
                  ),
                  initialCountryCode: 'EG',
                  pickerDialogStyle: PickerDialogStyle(
                    countryCodeStyle: const TextStyle(fontSize: 11),
                    countryNameStyle: const TextStyle(fontSize: 11),
                    searchFieldInputDecoration: InputDecoration(
                      hintText: 'Search country',
                      hintStyle: const TextStyle(color: AppTheme.textDimmed, fontSize: 11),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    listTilePadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                    padding: const EdgeInsets.all(24),
                  ),
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordCtrl,
                  hint: 'Password',
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
                    onPressed: _createAccount,
                    child: const Text('Create Account'),
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
                    const Text('Already have an account?',
                        style: TextStyle(
                            color: AppTheme.textGrey, fontSize: 14)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/signin'),
                      child: const Text(
                        'Sign In',
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
      style: const TextStyle(color: AppTheme.textWhite),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        errorStyle: const TextStyle(color: AppTheme.red),
        prefixIcon: Icon(icon, color: AppTheme.textDimmed, size: 20),
        suffixIcon: suffix,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 1.5),
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
            : Text(
                label,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}
