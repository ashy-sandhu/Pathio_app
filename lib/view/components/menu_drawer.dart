import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Pathio'),
        content: const Text(
          'Pathio\nVersion 1.0.0\n\nYour Path, Perfected.\n\nDiscover amazing places around the world and plan your perfect trips.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            )
          : null,
      onTap: onTap,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;
    final user = authProvider.user;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header with user info or login prompt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: isAuthenticated && user != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  user.displayName?[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.displayName ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 48,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Login / Sign Up'),
                        ),
                      ],
                    ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Navigation Section
                  _buildMenuItem(
                    context: context,
                    icon: Icons.home,
                    title: 'Home',
                    subtitle: 'Discover places',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home?tab=0');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.search,
                    title: 'Search',
                    subtitle: 'Find places',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home?tab=1');
                    },
                  ),

                  _buildDivider(),

                  // My Activity Section (requires auth)
                  if (isAuthenticated) ...[
                    _buildMenuItem(
                      context: context,
                      icon: Icons.bookmark,
                      title: 'Saved Places',
                      subtitle: 'Your favorite destinations',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/saved-places');
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.flight_takeoff,
                      title: 'My Trips',
                      subtitle: 'Your travel plans',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/home?tab=2');
                      },
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.rate_review,
                      title: 'My Reviews',
                      subtitle: 'Reviews you\'ve written',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/home?tab=3');
                      },
                    ),
                    _buildDivider(),
                  ],

                  // Settings Section
                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.person,
                    title: 'Account',
                    subtitle: 'Profile and account settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/home?tab=4');
                    },
                  ),

                  _buildDivider(),

                  // Information Section
                  _buildMenuItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: () => _showAboutDialog(context),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/help-support');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your data',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/privacy-policy');
                    },
                  ),

                  const SizedBox(height: 16),

                  // Logout button (if authenticated)
                  if (isAuthenticated)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

