import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../components/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Information We Collect',
              [
                'We collect information that you provide directly to us when you:',
                '• Create an account or profile',
                '• Use our services to search for places',
                '• Save favorite places',
                '• Write reviews or ratings',
                '• Contact us for support',
                '',
                'This information may include your name, email address, profile picture, and travel preferences.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '2. How We Use Your Information',
              [
                'We use the information we collect to:',
                '• Provide and improve our services',
                '• Personalize your experience',
                '• Send you important updates and notifications',
                '• Respond to your inquiries and requests',
                '• Analyze usage patterns to improve our app',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '3. Information Sharing',
              [
                'We do not sell, trade, or rent your personal information to third parties. We may share your information only:',
                '• With your explicit consent',
                '• To comply with legal obligations',
                '• To protect our rights and safety',
                '• With service providers who assist us in operating our app',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '4. Data Security',
              [
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                '',
                'However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '5. Your Rights',
              [
                'You have the right to:',
                '• Access your personal information',
                '• Correct inaccurate information',
                '• Delete your account and data',
                '• Opt-out of certain communications',
                '• Request a copy of your data',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '6. Cookies and Tracking',
              [
                'We may use cookies and similar tracking technologies to track activity on our app and hold certain information.',
                '',
                'You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '7. Children\'s Privacy',
              [
                'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '8. Changes to This Policy',
              [
                'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
                '',
                'You are advised to review this Privacy Policy periodically for any changes.',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '9. Contact Us',
              [
                'If you have any questions about this Privacy Policy, please contact us at:',
                '',
                'Email: support@travelguideapp.com',
                '',
                'We will respond to your inquiry within a reasonable timeframe.',
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            )),
      ],
    );
  }
}

