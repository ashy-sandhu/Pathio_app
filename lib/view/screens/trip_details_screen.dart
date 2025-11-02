import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/auth_provider.dart';
import '../../state/providers/user_profile_provider.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/place_model.dart';
import '../components/custom_app_bar.dart';
import '../components/place_details_sheet.dart';
import '../screens/place_card.dart';

class TripDetailsScreen extends StatefulWidget {
  final String tripId;

  const TripDetailsScreen({super.key, required this.tripId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrip();
    });
  }

  void _loadTrip() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuthenticated) {
      // Trip should already be loaded in UserProfileProvider
      // If not found, reload trips
      final profileProvider = context.read<UserProfileProvider>();
      final trip = profileProvider.trips.firstWhere(
        (t) => t.id == widget.tripId,
        orElse: () => Trip(
          id: '',
          userId: '',
          name: '',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          places: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (trip.id.isEmpty) {
        profileProvider.loadTrips(userId: authProvider.user!.uid);
      }
    }
  }

  Future<void> _deleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final success = await context.read<UserProfileProvider>().deleteTrip(
            userId: authProvider.user!.uid,
            tripId: trip.id,
          );

      if (mounted) {
        if (success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.read<UserProfileProvider>().error ?? 'Failed to delete trip',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
      appBar: CustomAppBar(
        title: 'Trip Details',
        actions: [
          Consumer2<AuthProvider, UserProfileProvider>(
            builder: (context, authProvider, profileProvider, child) {
              final trip = profileProvider.trips.firstWhere(
                (t) => t.id == widget.tripId,
                orElse: () => Trip(
                  id: '',
                  userId: '',
                  name: '',
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  places: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );

              if (trip.id.isEmpty || !authProvider.isAuthenticated) {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    context.push('/trips/edit/${trip.id}', extra: trip);
                  } else if (value == 'delete') {
                    _deleteTrip(trip);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, UserProfileProvider>(
        builder: (context, authProvider, profileProvider, child) {
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Login Required',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          final trip = profileProvider.trips.firstWhere(
            (t) => t.id == widget.tripId,
            orElse: () => Trip(
              id: '',
              userId: '',
              name: '',
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              places: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          if (trip.id.isEmpty) {
            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'Trip not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trip header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        if (trip.description != null && trip.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            trip.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Places section
                Text(
                  'Places (${trip.places.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 16),

                if (trip.places.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.location_off,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No places added yet',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trip.places.length,
                      itemBuilder: (context, index) {
                        final place = trip.places[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          child: PlaceCard(
                            place: place,
                            onTap: () => _showPlaceDetails(place),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

