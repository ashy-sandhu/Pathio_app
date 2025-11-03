import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
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
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) => _buildProfileSection(
                context,
                authProvider.isAuthenticated ? authProvider.user : null,
              ),
            ),
            const SizedBox(height: 24),

            // My Activity Section
            _buildSection(
              context: context,
              title: 'MY ACTIVITY',
              items: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) => _buildMenuItem(
                    context: context,
                    icon: Icons.bookmark,
                    title: 'Saved Places',
                    subtitle: 'Your favorite destinations',
                    onTap: authProvider.isAuthenticated
                        ? () => context.push('/saved-places')
                        : () => _showLoginRequired(context),
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) => _buildMenuItem(
                    context: context,
                    icon: Icons.rate_review,
                    title: 'My Reviews',
                    subtitle: 'Reviews you\'ve written',
                    onTap: authProvider.isAuthenticated
                        ? () => context.push('/my-reviews')
                        : () => _showLoginRequired(context),
                  ),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) => _buildMenuItem(
                    context: context,
                    icon: Icons.flight_takeoff,
                    title: 'My Trips',
                    subtitle: 'Your travel plans',
                    onTap: authProvider.isAuthenticated
                        ? () => context.push('/trips')
                        : () => _showLoginRequired(context),
                  ),
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
                  onTap: () => context.push('/settings'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () => context.push('/settings'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'Choose your preferred language',
                  onTap: () => context.push('/settings'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.palette,
                  title: 'Theme',
                  subtitle: 'Light or dark mode',
                  onTap: () => context.push('/settings'),
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
                  onTap: () => context.push('/privacy-policy'),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => context.push('/help-support'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) =>
                  authProvider.isAuthenticated
                      ? _buildLogoutSection(context)
                      : _buildLoginSection(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, authUser) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
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
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: authUser?.photoUrl != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: authUser.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            authUser?.displayName ?? 'Guest User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            authUser?.email ?? 'Not logged in',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          // Edit Profile Button or Login Button
          if (authUser != null)
            OutlinedButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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
            color: AppColors.shadow.withValues(alpha: 0.1),
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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

  Widget _buildLoginSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => context.push('/login'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.login,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Login to Access All Features',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
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
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
