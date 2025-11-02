import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/places_provider.dart';
import '../../state/providers/location_provider.dart';
import '../../data/models/place_model.dart';
import '../components/custom_app_bar.dart';
import '../components/loading_shimmer.dart';
import '../components/error_widget.dart';
import '../components/place_details_sheet.dart';
import '../components/location_permission_dialog.dart';
import '../components/auto_scroll_list.dart';
import '../components/places_map_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final placesProvider = context.read<PlacesProvider>();
    final locationProvider = context.read<LocationProvider>();

    if (kDebugMode) {
      print('🔄 Initializing data...');
    }

    // Load data in parallel to reduce initialization time
    final futures = <Future>[];

    // Only initialize if data hasn't been loaded yet
    if (placesProvider.popularPlaces.isEmpty) {
      futures.add(placesProvider.loadPopularPlaces());
    }

    if (placesProvider.allPlaces.isEmpty) {
      futures.add(placesProvider.loadAllPlaces());
    }

    if (!locationProvider.hasLocation) {
      futures.add(locationProvider.initialize());
    }

    // Wait for all initial operations to complete
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    if (kDebugMode) {
      print('📍 Location status: ${locationProvider.hasLocation}');
      print('📍 Location error: ${locationProvider.error}');
    }

    // Load nearby places if we have location (this can be done after initial load)
    if (locationProvider.hasLocation) {
      if (kDebugMode) {
        print(
          '📍 Loading nearby places with location: ${locationProvider.currentLocation}',
        );
      }
      // Don't await this - let it load in background
      placesProvider
          .loadNearbyPlaces(
            lat: locationProvider.currentLocation!.latitude,
            lon: locationProvider.currentLocation!.longitude,
          )
          .then((_) {
            if (kDebugMode) {
              print(
                '📍 Nearby places loaded: ${placesProvider.nearbyPlaces.length}',
              );
            }
          });
    } else {
      if (kDebugMode) {
        print('📍 No location available, trying to get current location...');
      }
      // Try to get location if not available
      locationProvider.getCurrentLocation().then((_) {
        if (locationProvider.hasLocation) {
          if (kDebugMode) {
            print('📍 Got location: ${locationProvider.currentLocation}');
          }
          placesProvider
              .loadNearbyPlaces(
                lat: locationProvider.currentLocation!.latitude,
                lon: locationProvider.currentLocation!.longitude,
              )
              .then((_) {
                if (kDebugMode) {
                  print(
                    '📍 Nearby places loaded: ${placesProvider.nearbyPlaces.length}',
                  );
                }
              });
        } else {
          if (kDebugMode) {
            print('📍 Still no location available: ${locationProvider.error}');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: CustomAppBar(title: 'Travel Guide'),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          // Show permission dialog if needed
          if (locationProvider.shouldShowPermissionDialog) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLocationPermissionDialog(context, locationProvider);
            });
          }

          return RefreshIndicator(
            onRefresh: _initializeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Places Section
                  _buildPopularPlacesSection(),

                  const SizedBox(height: 24),

                  // Nearby Places Section
                  _buildNearbyPlacesSection(),

                  // Map Card Section - Only show if we have data to prevent unnecessary rendering
                  Consumer2<PlacesProvider, LocationProvider>(
                    builder:
                        (context, placesProvider, locationProvider, child) {
                          if (locationProvider.hasLocation &&
                              placesProvider.nearbyPlaces.isNotEmpty &&
                              placesProvider.nearbyPlaces.length <= 20) {
                            // Only show map if reasonable number of places
                            return PlacesMapCard(
                              nearbyPlaces: placesProvider.nearbyPlaces,
                              onPlaceTap: _navigateToDetails,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title, description, and explore more button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Special typography for title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Popular Places',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Descriptive text
                    Text(
                      'Discover the most visited and beloved destinations around the world',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Compact explore more button
              Consumer<PlacesProvider>(
                builder: (context, placesProvider, child) {
                  if (placesProvider.hasMorePopular) {
                    return _buildCompactExploreButton(
                      onTap: () => _navigateToExploreMore(
                        'popular',
                        placesProvider.popularPlaces,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        Consumer<PlacesProvider>(
          builder: (context, placesProvider, child) {
            if (placesProvider.isLoadingPopular) {
              return _buildLoadingPlacesList();
            }

            if (placesProvider.popularError != null) {
              return CustomErrorWidget(
                message: 'Failed to load popular places',
                onRetry: () => placesProvider.loadPopularPlaces(),
              );
            }

            if (placesProvider.popularPlaces.isEmpty) {
              return const EmptyStateWidget(
                message: 'No popular places found',
                icon: Icons.explore_off,
              );
            }

            return _buildPlacesList(placesProvider.popularPlaces);
          },
        ),
      ],
    );
  }

  Widget _buildNearbyPlacesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title, description, and explore more button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Special typography for title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const Text(
                        'Nearby Places',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Descriptive text
                    Text(
                      'Explore amazing destinations close to your current location',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Compact explore more button and refresh button
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<PlacesProvider>(
                    builder: (context, placesProvider, child) {
                      if (placesProvider.hasMoreNearby) {
                        return _buildCompactExploreButton(
                          onTap: () => _navigateToExploreMore(
                            'nearby',
                            placesProvider.nearbyPlaces,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(width: 8),
                  Consumer<LocationProvider>(
                    builder: (context, locationProvider, child) {
                      if (locationProvider.hasLocation) {
                        return _buildCompactRefreshButton(
                          onTap: () => _refreshNearbyPlaces(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        Consumer2<PlacesProvider, LocationProvider>(
          builder: (context, placesProvider, locationProvider, child) {
            // Show loading state while location is being fetched
            if (!locationProvider.hasLocation && locationProvider.isLoading) {
              return _buildLoadingPlacesList();
            }

            // If still no location after loading, show a simple message
            if (!locationProvider.hasLocation) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Center(
                  child: Text(
                    'Loading location...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              );
            }

            if (placesProvider.isLoadingNearby) {
              return _buildLoadingPlacesList();
            }

            if (placesProvider.nearbyError != null) {
              return CustomErrorWidget(
                message: 'Failed to load nearby places',
                onRetry: () => _refreshNearbyPlaces(),
              );
            }

            if (placesProvider.nearbyPlaces.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_searching,
                      size: 48,
                      color: Colors.orange[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No places found nearby',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching for a specific place or browse popular destinations',
                      style: TextStyle(fontSize: 14, color: Colors.orange[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Show special message if we're showing popular places as fallback
            if (placesProvider.nearbyError != null &&
                placesProvider.nearbyError!.contains(
                  'Showing popular places instead',
                )) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No places found nearby. Showing popular destinations instead.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPlacesList(placesProvider.nearbyPlaces),
                ],
              );
            }

            return _buildPlacesList(
              placesProvider.nearbyPlaces,
              reverseDirection: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingPlacesList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return const PlaceCardShimmer(width: 160, height: 200);
        },
      ),
    );
  }

  Widget _buildPlacesList(List<Place> places, {bool reverseDirection = false}) {
    // Calculate card width for 2.25 cards viewport (2 full + 0.25 peek)
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 32.0; // 16px on each side
    final availableWidth = screenWidth - horizontalPadding;
    final cardWidth = availableWidth / 2.25; // 2.25 cards visible

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AutoScrollList(
        places: places,
        height: 200,
        itemWidth: cardWidth,
        itemHeight: 200,
        onTap: _navigateToDetails,
        scrollDuration: const Duration(milliseconds: 500), // Quick transition
        pauseDuration: const Duration(seconds: 3), // Pause between steps
        reverseDirection: reverseDirection,
      ),
    );
  }

  Future<void> _refreshNearbyPlaces() async {
    final locationProvider = context.read<LocationProvider>();
    final placesProvider = context.read<PlacesProvider>();

    if (locationProvider.hasLocation) {
      await placesProvider.loadNearbyPlaces(
        lat: locationProvider.currentLocation!.latitude,
        lon: locationProvider.currentLocation!.longitude,
      );
    }
  }

  Widget _buildCompactExploreButton({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'More',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactRefreshButton({required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToExploreMore(String placeType, List<Place> places) {
    context.pushNamed(
      'explore-more',
      extra: {
        'placeType': placeType,
        'initialPlaces': places,
        'category': 'All',
      },
    );
  }

  void _showLocationPermissionDialog(
    BuildContext context,
    LocationProvider locationProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onAllow: () async {
          Navigator.of(context).pop();
          await locationProvider.onPermissionDialogResponse(true);
        },
        onDeny: () async {
          Navigator.of(context).pop();
          await locationProvider.onPermissionDialogResponse(false);
        },
      ),
    );
  }

  void _navigateToDetails(Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(place: place),
    );
  }
}
