import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../data/app_state.dart';
import '../localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _resetPassword() async {
    final email = Supabase.instance.client.auth.currentUser?.email ?? AppState.userEmail;
    if (email != null && email.isNotEmpty) {
      try {
        await Supabase.instance.client.auth.resetPasswordForEmail(email);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No email found to reset password.'.tr), backgroundColor: AppTheme.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: Text('Settings'.tr, style: TextStyle(color: AppTheme.textWhite)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information'.tr,
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name'.tr, AppState.userName ?? 'User'.tr),
            _buildInfoRow('Email'.tr, Supabase.instance.client.auth.currentUser?.email ?? AppState.userEmail ?? 'Not set'),
            
            const SizedBox(height: 32),
            Text(
              'Security'.tr,
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _settingsOption(Icons.lock_reset_outlined, 'Reset Password'.tr, onTap: _resetPassword),
            
            const SizedBox(height: 32),
            Text(
              'Preferences'.tr,
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _settingsOption(
              AppTheme.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              'Theme Mode'.tr,
              trailing: Text(
                AppTheme.isDark ? 'Dark Mode'.tr : 'Light Mode'.tr,
                style: TextStyle(color: AppTheme.textGrey),
              ),
              onTap: () async {
                await AppTheme.toggleTheme();
                setState(() {});
              },
            ),
            _settingsOption(Icons.notifications_none, 'Notifications'.tr, onTap: () {}),
            _settingsOption(
              Icons.language,
              'Language'.tr,
              trailing: Text(Loc.isArabic ? 'العربية' : 'English'.tr, style: TextStyle(color: AppTheme.textGrey)),
              onTap: () async {
                await Loc.toggleLanguage();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textWhite, fontSize: 16)),
          Text(value, style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _settingsOption(IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accentPurple, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
            if (trailing != null) const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppTheme.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }
}
