import 'package:flutter/material.dart';
import '../main.dart';
import '../data/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Profile Header
              const Text(
                'My Profile',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Avatar with Edit Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryPurple, width: 3),
                      color: AppTheme.bgCardLight,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: AppTheme.textDimmed,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Logic to change photo
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // User Info
              Text(
                AppState.userName ?? 'User',
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppState.userEmail ?? 'user@example.com',
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),



              // Other Profile Options (Examples)
              _profileOption(Icons.settings_outlined, 'Settings'),

              _profileOption(Icons.help_outline, 'Help Center'),
              const SizedBox(height: 40),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await AppState.clearUserInfo();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/signin');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.red,
                    side: const BorderSide(color: AppTheme.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _profileOption(IconData icon, String title) {
    return Container(
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
          const Icon(Icons.chevron_right, color: AppTheme.textDimmed, size: 20),
        ],
      ),
    );
  }
}
