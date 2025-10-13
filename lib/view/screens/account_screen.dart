import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../components/custom_app_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Account',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(context),
            const SizedBox(height: 24),

            // My Activity Section
            _buildSection(
              context: context,
              title: 'MY ACTIVITY',
              items: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.bookmark,
                  title: 'Saved Places',
                  subtitle: 'Your favorite destinations',
                  onTap: () => _showComingSoon(context, 'Saved Places'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.rate_review,
                  title: 'My Reviews',
                  subtitle: 'Reviews you\'ve written',
                  onTap: () => _showComingSoon(context, 'My Reviews'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.history,
                  title: 'Trip History',
                  subtitle: 'Places you\'ve visited',
                  onTap: () => _showComingSoon(context, 'Trip History'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preferences Section
            _buildSection(
              context: context,
              title: 'PREFERENCES',
              items: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences and configuration',
                  onTap: () => _showComingSoon(context, 'Settings'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => _showComingSoon(context, 'Notifications'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Choose your preferred language',
                  onTap: () => _showComingSoon(context, 'Language'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: 'Light or dark mode',
                  onTap: () => _showComingSoon(context, 'Theme'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Information Section
            _buildSection(
              context: context,
              title: 'INFORMATION',
              items: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your data',
                  onTap: () => _showComingSoon(context, 'Privacy Policy'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _showComingSoon(context, 'Help & Support'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Section
            _buildLogoutSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            'john.doe@example.com',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Edit Profile Button
          OutlinedButton.icon(
            onPressed: () => _showComingSoon(context, 'Edit Profile'),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('$feature feature will be available soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Travel Guide',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.travel_explore,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text('Discover amazing places around the world with our travel guide app.'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Logout');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
