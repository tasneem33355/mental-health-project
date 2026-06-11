import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../data/app_state.dart';

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
            const SnackBar(content: Text('Password reset link sent to your email'), backgroundColor: AppTheme.green),
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
        const SnackBar(content: Text('No email found to reset password.'), backgroundColor: AppTheme.red),
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
        title: const Text('Settings', style: TextStyle(color: AppTheme.textWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', AppState.userName ?? 'User'),
            _buildInfoRow('Email', Supabase.instance.client.auth.currentUser?.email ?? AppState.userEmail ?? 'Not set'),
            
            const SizedBox(height: 32),
            const Text(
              'Security',
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _settingsOption(Icons.lock_reset_outlined, 'Reset Password', onTap: _resetPassword),
            
            const SizedBox(height: 32),
            const Text(
              'Preferences',
              style: TextStyle(color: AppTheme.accentPurple, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _settingsOption(Icons.notifications_none, 'Notifications', onTap: () {}),
            _settingsOption(Icons.language, 'Language', trailing: const Text('English', style: TextStyle(color: AppTheme.textGrey))),
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
          Text(label, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16)),
          Text(value, style: const TextStyle(color: AppTheme.textGrey, fontSize: 16)),
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
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
            if (trailing != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textDimmed, size: 20),
          ],
        ),
      ),
    );
  }
}
