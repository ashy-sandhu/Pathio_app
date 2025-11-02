import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/user_profile_provider.dart';
import '../../data/models/place_model.dart';
import '../components/custom_app_bar.dart';
import '../screens/place_card.dart';
import '../components/error_widget.dart';
import '../components/place_details_sheet.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPlaces();
    });
  }

  void _loadSavedPlaces() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      context.read<UserProfileProvider>().loadSavedPlaces(
            userId: authProvider.user!.uid,
          );
    }
  }

  Future<void> _removePlace(String placeId) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Place'),
        content: const Text('Are you sure you want to remove this place from your saved list?'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<UserProfileProvider>().removePlace(
            userId: authProvider.user!.uid,
            placeId: placeId,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Place removed' : 'Failed to remove place',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(place: place),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Saved Places'),
      body: Consumer2<AuthProvider, UserProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          // Check if user is authenticated
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Required',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to view your saved places',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          // Loading state
          if (profileProvider.isLoading && profileProvider.savedPlaces.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (profileProvider.error != null && profileProvider.savedPlaces.isEmpty) {
            return CustomErrorWidget(
              message: profileProvider.error!,
              onRetry: _loadSavedPlaces,
            );
          }

          final savedPlaces = profileProvider.savedPlaces;

          if (savedPlaces.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.bookmark_border,
              message: 'No saved places\n\nSave your favorite places to see them here!',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadSavedPlaces(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: savedPlaces.length,
              itemBuilder: (context, index) {
                final savedPlace = savedPlaces[index];
                final place = savedPlace.placeData;

                if (place == null) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: [
                    PlaceCard(
                      place: place,
                      onTap: () => _showPlaceDetails(place),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        child: IconButton(
                          icon: const Icon(Icons.bookmark, color: AppColors.primary),
                          iconSize: 20,
                          onPressed: () => _removePlace(place.id.toString()),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

