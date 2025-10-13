import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsService {
  // Open location in Google Maps
  static Future<void> openInGoogleMaps({
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    final String query = placeName != null ? placeName : '$latitude,$longitude';

    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$query';

    try {
      // Try to open Google Maps first
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        // Fallback to Apple Maps
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('No maps application available');
      }
    } catch (e) {
      throw Exception('Failed to open maps: $e');
    }
  }

  // Show app chooser for maps
  static Future<void> showMapsChooser({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? placeName,
  }) async {
    final String query = placeName != null ? placeName : '$latitude,$longitude';

    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$query';
    final String coordinates = '$latitude,$longitude';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Open in Maps',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMapsOption(
              context: context,
              title: 'Google Maps',
              subtitle: 'Open in Google Maps app',
              icon: Icons.map,
              onTap: () async {
                Navigator.pop(context);
                await _launchMaps(googleMapsUrl);
              },
            ),
            const SizedBox(height: 12),
            _buildMapsOption(
              context: context,
              title: 'Apple Maps',
              subtitle: 'Open in Apple Maps app',
              icon: Icons.apple,
              onTap: () async {
                Navigator.pop(context);
                await _launchMaps(appleMapsUrl);
              },
            ),
            const SizedBox(height: 12),
            _buildMapsOption(
              context: context,
              title: 'Copy Coordinates',
              subtitle: 'Copy location coordinates',
              icon: Icons.copy,
              onTap: () async {
                Navigator.pop(context);
                await _copyCoordinates(context, coordinates);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildMapsOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchMaps(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch maps application');
      }
    } catch (e) {
      throw Exception('Failed to open maps: $e');
    }
  }

  static Future<void> _copyCoordinates(
    BuildContext context,
    String coordinates,
  ) async {
    await Clipboard.setData(ClipboardData(text: coordinates));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coordinates copied: $coordinates'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
