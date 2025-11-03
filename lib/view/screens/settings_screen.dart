import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/theme_provider.dart';
import '../components/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveLanguageSetting(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    setState(() => _selectedLanguage = language);
  }

  Future<void> _saveThemeSetting(bool isDark) async {
    final themeProvider = context.read<ThemeProvider>();
    await themeProvider.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Settings
          _buildSection(
            title: 'PROFILE',
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your profile information',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _buildMenuItem(
                icon: Icons.photo_camera_outlined,
                title: 'Change Photo',
                subtitle: 'Update your profile picture',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Preferences
          _buildSection(
            title: 'PREFERENCES',
            children: [
              SwitchListTile(
                secondary: Icon(Icons.notifications_outlined, color: AppColors.primary),
                title: const Text('Notifications'),
                subtitle: const Text('Receive push notifications'),
                value: _notificationsEnabled,
                onChanged: _saveNotificationSetting,
                activeColor: AppColors.primary,
              ),
              _buildMenuItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: _selectedLanguage,
                onTap: () => _showLanguageDialog(),
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    secondary: Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) => _saveThemeSetting(value),
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Privacy & Security
          _buildSection(
            title: 'PRIVACY & SECURITY',
            children: [
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
              ),
              _buildMenuItem(
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Manage account security',
                onTap: () => Navigator.pushNamed(context, '/security'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account
          _buildSection(
            title: 'ACCOUNT',
            children: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (!authProvider.isAuthenticated) {
                    return _buildMenuItem(
                      icon: Icons.login,
                      title: 'Login',
                      subtitle: 'Sign in to your account',
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    );
                  }
                  return _buildMenuItem(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    onTap: () => _showDeleteAccountDialog(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Italian'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages
              .map(
                (lang) => RadioListTile<String>(
                  title: Text(lang),
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.pop(context);
                      _saveLanguageSetting(value);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _showDeleteAccountConfirmation();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you absolutely sure? This action cannot be undone and will permanently delete:',
              ),
              const SizedBox(height: 12),
              const Text('• Your account'),
              const Text('• All saved places'),
              const Text('• All trips'),
              const Text('• All reviews'),
              const Text('• All uploaded photos'),
              const SizedBox(height: 16),
              const Text(
                'Please enter your password to confirm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, passwordController.text);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed is String) {
      // User confirmed deletion with password
      _deleteAccount(confirmed);
    }
  }

  Future<void> _deleteAccount(String password) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Final Confirmation'),
          content: const Text(
            'This is your last chance. Are you absolutely certain you want to delete your account?',
          ),
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
              child: const Text('Yes, Delete Forever'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        
        final success = await authProvider.deleteAccount(password: password);
        
        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Failed to delete account'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

